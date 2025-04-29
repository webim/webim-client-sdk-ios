//
//  ShareViewController.swift
//  WebimClientShare
//
//  Created by Anna Frolova on 05.09.2022.
//  Copyright © 2022 Webim. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit
import Social
import WebimMobileSDK
import MobileCoreServices
import UniformTypeIdentifiers
import Foundation

@objc(WMShareViewController)
class WMShareViewController: UIViewController, SendFileCompletionHandler {
    
    private var alertController: UIAlertController!
    var sendFileError: SendFileError?
    let saveView = WMSaveView.loadXibView()
    lazy var shareProgressViewController = WMShareProgressViewController.loadViewControllerFromXib()
    var sendedFilesCount = 0
    var countOfAttachments = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        WMKeychainWrapper.standard.setAppGroupName(userDefaults: UserDefaults(suiteName: "group.WebimClient.Share") ?? UserDefaults.standard,
                                                   keychainAccessGroup: Bundle.main.infoDictionary!["keychainAppIdentifier"] as! String)
        WebimServiceController.currentSessionShare.createSession()
        WebimServiceController.currentSession.setMessageTracker(withMessageListener: self)
        getFilesExtensionContext()
    }
    
    func getFilesExtensionContext() {
        guard let inputItems = extensionContext?.inputItems as? [NSExtensionItem], inputItems.isNotEmpty() else {
            close()
            return
        }
       
        inputItems.forEach { item in
            item.attachments?.forEach { attachment in
                handleAttachment(attachment)
                countOfAttachments += 1
            }
        }
        
        showShareProgressView()
    }
    
    private func showShareProgressView() {
        shareProgressViewController.modalPresentationStyle = .overCurrentContext
        present(shareProgressViewController, animated: true)
    }
    
    func showDialog(
        withMessage message: String,
        title: String?,
        buttonTitle: String = "OK".localized,
        buttonStyle: UIAlertAction.Style = .cancel,
        action: (() -> Void)? = nil
    ) {
        alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let alertAction = UIAlertAction(
            title: buttonTitle,
            style: buttonStyle,
            handler: { _ in
                self.close()
            })
        
        alertController.addAction(alertAction)
        
        if buttonStyle != .cancel {
            let alertActionOther = UIAlertAction(
                title: "Cancel".localized,
                style: .cancel)
            alertController.addAction(alertActionOther)
        }
        
        self.present(alertController, animated: true)
    }
    
    func checkErrorAfterSend() {
        guard sendFileError != nil else {
            self.saveView.stopAnimateActivity()
            self.saveView.animateImage()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.close()
            }
            return
        }
        DispatchQueue.main.async {
            var message = "File sending unknown error".localized
            switch self.sendFileError {
            case .fileSizeExceeded:
                message = "File is too large.".localized
            case .fileTypeNotAllowed:
                message = "File type is not supported".localized
            case .unknown:
                message = "File sending unknown error".localized
            case .uploadedFileNotFound:
                message = "Sending files in body is not supported".localized
            case .unauthorized:
                message = "Failed to upload file: visitor is not logged in".localized
            case .maxFilesCountPerChatExceeded:
                message = "MaxFilesCountExceeded".localized
            case .fileSizeTooSmall:
                message = "File is too small".localized
            default:
                break
            }
            self.showDialog(
                withMessage: message,
                title: "File sending failed".localized,
                buttonTitle: "OK".localized
            )
        }
    }
}

extension WMShareViewController {
    
    func close() {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    func handleAttachment(_ attachment: NSItemProvider) {
        if attachment.isImage {
            handleImageAttachment(attachment)
        } else if attachment.isFile {
            handleFileAttachment(attachment, UTType.fileURL.identifier)
        } else if let type = attachment.isVideo {
            handleFileAttachment(attachment, type)
        }
    }
    
    func handleImageAttachment(_ attachment: NSItemProvider) {
        attachment.loadItem(forTypeIdentifier: UTType.image.identifier,
                            options: nil) { [weak self] item, error in
            guard let self = self else { return }
            guard error == nil else {
                self.close()
                return
            }
            var imageData = Data()
            var imageName = String()
            var mimeType = String()
            if let imageURL = item as? URL, let data = try? Data(contentsOf: imageURL) {
                imageData = data
                mimeType = MimeType(url: imageURL as URL).value
                imageName = imageURL.lastPathComponent
                let imageExtension = imageURL.pathExtension.lowercased()
                
                switch imageExtension {
                case "jpg", "jpeg": break
                case "heic", "heif":
                    var components = imageName.components(separatedBy: ".")
                    if components.count > 1 {
                        components.removeLast()
                        imageName = components.joined(separator: ".")
                    }
                    imageName += ".jpeg"
                default:
                    break
                }
            } else if let image = item as? UIImage {
                guard let unwrappedData = image.jpegData(compressionQuality: 1.0)
                else { return }
                imageData = unwrappedData
                imageName = "photo.jpeg"
            }

            DispatchQueue.main.sync {
                WebimServiceController.currentSession.sendFile(data: imageData,
                                                               fileName: imageName,
                                                               mimeType: mimeType,
                                                               completionHandler: self)
            }
        }
    }
    
    func handleFileAttachment(_ attachment: NSItemProvider, _ typeIdentifier: String) {
        attachment.loadItem(forTypeIdentifier: typeIdentifier, options: nil) { [weak self] item, error in
            guard let self = self else { return }
            guard error == nil else {
                self.close()
                return
            }
            var fileData = Data()
            var fileName = String()
            var mimeType = MimeType()
            if let fileURL = item as? URL, let data = try? Data(contentsOf: fileURL) {
                fileData = data
                mimeType = MimeType(url: fileURL as URL)
                fileName = fileURL.lastPathComponent
            }
            
            DispatchQueue.main.sync {
                WebimServiceController.currentSession.sendFile(data: fileData,
                                                               fileName: fileName,
                                                               mimeType: mimeType.value,
                                                               completionHandler: self)
            }
        }
    }
    
    func onSuccess(messageID: String) {
    }
    
    func onFailure(messageID: String, error: SendFileError) {
        sendFileError = error
    }
}

extension NSItemProvider {
    var isImage: Bool {
        return hasItemConformingToTypeIdentifier(UTType.image.identifier)
    }

    var isFile: Bool {
        return hasItemConformingToTypeIdentifier(UTType.fileURL.identifier)
    }

    var isVideo: String? {
        if hasItemConformingToTypeIdentifier(UTType.video.identifier) {
            return (UTType.video.identifier)
        } else if hasItemConformingToTypeIdentifier(UTType.mpeg.identifier) {
            return (UTType.mpeg.identifier)
        } else if hasItemConformingToTypeIdentifier(UTType.mpeg4Movie.identifier) {
            return (UTType.mpeg4Movie.identifier)
        } else {
            return ""
        }
    }
}

extension Array {
    func isNotEmpty() -> Bool {
        return !isEmpty
    }
}

extension WMShareViewController: MessageListener {
    func removed(message: any WebimMobileSDK.Message) {
    }
    
    func removedAllMessages() {
    }
    
    func added(message newMessage: Message,
               after previousMessage: Message?) {
        if let fileData = newMessage.getData()?.getAttachment()?.getFileInfo() {
            self.shareProgressViewController.startProgress(for: SendingFile(fileName: fileData.getFileName(),
                                                                            fileID: newMessage.getID()))
        }
        
    }
    
    func changed(message oldVersion: Message,
                 to newVersion: Message) {
        if let fileData = newVersion.getData()?.getAttachment()?.getFileInfo() {
            self.shareProgressViewController.stateChanged(for: SendingFile(fileName: fileData.getFileName(),
                                                                           fileID: oldVersion.getID()),
                                                          with: newVersion.getSendStatus())
        }
    }
}
