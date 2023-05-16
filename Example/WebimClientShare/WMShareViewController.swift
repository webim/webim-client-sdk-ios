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
import WebimClientLibrary
import MobileCoreServices
import UniformTypeIdentifiers
import Foundation


@objc(WMShareViewController)
class WMShareViewController: UIViewController, SendFileCompletionHandler {
    
    private var alertController: UIAlertController!
    var sendFileError: SendFileError? = nil
    let saveView = WMSaveView.loadXibView()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        WMKeychainWrapper.standard.setAppGroupName(userDefaults: UserDefaults(suiteName: "group.WebimClient.Share") ?? UserDefaults.standard, keychainAccessGroup: Bundle.main.infoDictionary!["keychainAppIdentifier"] as! String)

        WebimServiceController.currentSessionShare.createSession()

        alertController = UIAlertController(title: "Отправить файл".localized,
                                            message: "Вы уверены что хотите отправить файл?",
                                            preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK".localized,
                                     style: .default,
                                     handler: { _ in self.getFilesExtensionContext() })
        
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }
    
    func getFilesExtensionContext() {
        guard let inputItems = extensionContext?.inputItems as? [NSExtensionItem], inputItems.isNotEmpty() else {
            close()
            return
        }
        
        DispatchQueue.main.async {
            self.view.addSubview(self.saveView)
            self.saveView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            self.saveView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        }
        self.saveView.animateActivity()
        inputItems.forEach { item in
            if let attachments = item.attachments,
               !attachments.isEmpty {
                attachments.forEach { attachment in
                    if attachment.isImage {
                        handleImageAttachment(attachment)
                    } else if attachment.isFile {
                        handleFileAttachment(attachment)
                    }
                }
            }
        }
        checkErrorAfterSend()
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
            var message = "Find sending unknown error".localized
            switch self.sendFileError {
            case .fileSizeExceeded:
                message = "File is too large.".localized
            case .fileTypeNotAllowed:
                message = "File type is not supported".localized
            case .unknown:
                message = "Find sending unknown error".localized
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
    
    func handleImageAttachment(_ attachment: NSItemProvider) {
        attachment.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil) { [weak self] item, error in
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
    
    func handleFileAttachment(_ attachment: NSItemProvider) {
        attachment.loadItem(forTypeIdentifier: kUTTypeFileURL as String, options: nil) { [weak self] item, error in
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
        return hasItemConformingToTypeIdentifier(kUTTypeImage as String)
    }
    
    var isFile: Bool {
        return hasItemConformingToTypeIdentifier(kUTTypeFileURL as String)
    }
}

extension Array {
    func isNotEmpty() -> Bool {
        return !isEmpty
    }
}
