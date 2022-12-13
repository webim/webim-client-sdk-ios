//
//  FilePicker.swift
//  WebimClientLibrary_Example
//
//  Created by Eugene Ilyin on 21.10.2019.
//  Copyright © 2019 Webim. All rights reserved.
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
import MobileCoreServices
import AVFoundation
import CloudKit
import AVKit
import Photos
import PhotosUI

public typealias ImageToSend = (image: UIImage?, url: URL?)
public typealias FileToSend = (file: Data?, url: URL?)

public protocol FilePickerDelegate: AnyObject {
    func didSelect(images: [ImageToSend])
    func didSelect(files: [FileToSend])
}

open class FilePicker: NSObject {
    
    // MARK: - Private properties
    private let imagePickerController: UIImagePickerController
    private let documentPickerController: UIDocumentPickerViewController
    private let alertDialogHandler: UIAlertHandler
    
    private weak var presentationController: UIViewController?
    private weak var delegate: FilePickerDelegate?
    
    // MARK: - Methods
    public init(presentationController: UIViewController,
                delegate: FilePickerDelegate) {
        self.imagePickerController = UIImagePickerController()
        self.documentPickerController = UIDocumentPickerViewController(
            documentTypes: [
                String(kUTTypeJPEG),
                String(kUTTypeRTF),
                String(kUTTypeGIF),
                String(kUTTypePlainText),
                String(kUTTypePDF),
                String(kUTTypeMP3),
                String(kUTTypeMPEG4),
                String(kUTTypeData),
                String(kUTTypeArchive)
            ],
            in: .import
        )
        self.alertDialogHandler = UIAlertHandler(delegate: presentationController)
        
        super.init()
        
        self.presentationController = presentationController
        self.delegate = delegate
        
        self.imagePickerController.delegate = self
        self.imagePickerController.allowsEditing = false
        self.imagePickerController.mediaTypes = ["public.image"]

        self.documentPickerController.delegate = self
        if #available(iOS 11.0, *) {
            self.documentPickerController.allowsMultipleSelection = true
        }
    }
    
    public func showSendFileMenu(from sourceView: UIView) {
        let fileMenuSheet = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let cameraAction = UIAlertAction(
            title: "Camera".localized,
            style: .default,
            handler: { _ in
                let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
                switch cameraAuthorizationStatus {
                case .notDetermined:
                    self.requesetCameraPermission()
                case .authorized:
                    self.presentCamera()
                case .restricted, .denied:
                    self.showAlertForCameraAccess()
                @unknown default:
                    // Handle possibly added (in future) values
                    break
                }
            }
        )
        
        let photoLibraryAction = UIAlertAction(
            title: "Photo Library".localized,
            style: .default,
            handler: { _ in
                self.showPhotoLibrary()
            }
        )
        
        let fileAction = UIAlertAction(
            title: "File".localized,
            style: .default,
            handler: { _ in
                self.presentationController?.present(
                    self.documentPickerController,
                    animated: true)
            }
        )
        
        let cancelAction = UIAlertAction(
            title: "Cancel".localized,
            style: .cancel
        )
        
        fileMenuSheet.addAction(cameraAction)
        fileMenuSheet.addAction(photoLibraryAction)
        fileMenuSheet.addAction(cancelAction)
        
        /// Files App was presented in iOS 11.0
        if #available(iOS 11.0, *) {
            fileMenuSheet.addAction(fileAction)
        }
        
        // Workaround for iPads
        if UIDevice.current.userInterfaceIdiom == .pad {
            fileMenuSheet.popoverPresentationController?.sourceView = sourceView
            fileMenuSheet.popoverPresentationController?.sourceRect = sourceView.bounds
            fileMenuSheet.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }
        self.presentationController?.present(fileMenuSheet, animated: true)
    }
    
    private func showPhotoLibrary() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            self.requesetPhotoPermission()
        case .authorized, .limited:
            self.presentPhoto()
        case .restricted, .denied:
            self.showAlertForPhotoAccess()
        @unknown default:
            // Handle possibly added (in future) values
            break
        }
    }
    
    private func requesetPhotoPermission() {
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                if status == .limited || status == .authorized {
                    self.presentPhoto()
                }
            }
        } else {
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    self.presentPhoto()
                }
            }
        }
    }
    
    private func presentPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            DispatchQueue.main.async {
                self.showImagePicker()
            }
        } else {
            let ac = UIAlertController(
                title: "Please Allow Access".localized,
                message: "Need photo access".localized,
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(
                title: "OK".localized,
                style: .cancel
            )
            
            ac.addAction(okAction)
            
            self.presentationController?.present(ac, animated: true)
        }
    }
    
    private func showAlertForPhotoAccess() {
        
        let ac = UIAlertController(
            title: "Please Allow Access".localized,
            message: "Need photo access".localized,
            preferredStyle: .alert
        )
        guard let settingsAppURL = URL(string: UIApplication.openSettingsURLString) else { return }
        let showAppSettingsAction = UIAlertAction(
            title: "Settings".localized,
            style: .default,
            handler: { _ in
                UIApplication.shared.open(
                    settingsAppURL,
                    options: [:])
            }
        )
        
        let cancelAction = UIAlertAction(
            title: "Cancel".localized,
            style: .cancel
        )
        
        ac.addAction(showAppSettingsAction)
        ac.addAction(cancelAction)
        
        self.presentationController?.present(ac, animated: true)
    }
    
    private func showImagePicker() {
        if #available(iOS 14, *) {
            self.presentationController?.present(producePickerViewController(), animated: true)
        } else {
            self.imagePickerController.sourceType = .photoLibrary
            self.presentationController?.present(
                self.imagePickerController,
                animated: true
            )
        }
    }
    
    // MARK: - Private methods
    private func pickerControllerImage(_ controller: UIImagePickerController, didSelect images: [ImageToSend] = []) {
        controller.dismiss(animated: true, completion: nil)
        self.delegate?.didSelect(images: images)
    }
    
    private func pickerControllerDocument(_ controller: UIDocumentPickerViewController, didSelect files: [FileToSend] = []) {
        controller.dismiss(animated: true, completion: nil)
        self.delegate?.didSelect(files: files)
    }
    
    private func requesetCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { (access) in
            guard access == true else { return }
            self.presentCamera()
        }
    }
    
    private func presentCamera() {
        DispatchQueue.main.async {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePickerController.sourceType = .camera
                self.presentationController?.present(self.imagePickerController, animated: true)
            } else {
                let ac = UIAlertController(
                    title: "Camera is not available".localized,
                    message: nil,
                    preferredStyle: .alert
                )
                
                let okAction = UIAlertAction(
                    title: "OK".localized,
                    style: .cancel
                )
                
                ac.addAction(okAction)
                
                self.presentationController?.present(ac, animated: true)
            }
        }
    }
    
    private func showAlertForCameraAccess() {
        guard let settingsAppURL = URL(string: UIApplication.openSettingsURLString) else { return }
        
        let ac = UIAlertController(
            title: "Need camera access".localized,
            message: "Webim needs permission to access your camera so you can send photos to chat.".localized,
            preferredStyle: .alert
        )
        
        let showAppSettingsAction = UIAlertAction(
            title: "Open app settings".localized,
            style: .default,
            handler: { _ in
                UIApplication.shared.open(
                    settingsAppURL,
                    options: [:])
            }
        )
        
        let cancelAction = UIAlertAction(
            title: "Cancel".localized,
            style: .cancel
        )
        
        ac.addAction(showAppSettingsAction)
        ac.addAction(cancelAction)
        
        self.presentationController?.present(ac, animated: true)
    }

    @available(iOS 14, *)
    private func producePickerViewController() -> PHPickerViewController {
        var pickerConfig = PHPickerConfiguration(photoLibrary: .shared())
        pickerConfig.selectionLimit = 10
        let picker = PHPickerViewController(configuration: pickerConfig)
        picker.delegate = self
        return picker
    }
}

// MARK: - UIImagePickerController extensions
extension FilePicker: UIImagePickerControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerControllerImage(picker)
    }
    
    public func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        guard let image = info[.originalImage] as? UIImage else {
            return self.pickerControllerImage(picker)
        }
        
        guard let imageURL = info[.referenceURL] as? URL else {
            return self.pickerControllerImage(picker, didSelect: [ImageToSend(image: image, url: nil)])
        }
        
        self.pickerControllerImage(picker, didSelect: [ImageToSend(image: image, url: imageURL)]
        )
    }
}

extension FilePicker: PHPickerViewControllerDelegate {
    @available(iOS 14, *)
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        var images: [ImageToSend] = []
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                guard error == nil else {
                    DispatchQueue.main.async {
                        self?.alertDialogHandler.showFileLoadingFailureDialog()
                    }
                    return
                }
                guard let image = image as? UIImage else { return }
                images.append(ImageToSend(image: image, url: nil))
                guard images.count == results.count else { return }
                DispatchQueue.main.async {
                    self?.delegate?.didSelect(images: images)
                }
            }
        }
    }
}

extension FilePicker: UIDocumentMenuDelegate, UIDocumentPickerDelegate {
    public func documentPicker(_ picker: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        picker.dismiss(animated: true)
        var files: [FileToSend] = []
        for url in urls {
            do {
                let data = try Data(contentsOf: url)
                files.append(FileToSend(file: data, url: url))
                guard urls.count == files.count else { continue }
                self.pickerControllerDocument(picker, didSelect: files)
            } catch {
                alertDialogHandler.showFileLoadingFailureDialog()
            }
        }
    }
    
    public func documentMenu(
        _ documentMenu: UIDocumentMenuViewController,
        didPickDocumentPicker documentPicker: UIDocumentPickerViewController
    ) {
        // TODO: Check what for this method is responsible
        documentPicker.delegate = self
        self.presentationController?.present(documentPicker, animated: true)
    }
        
    public func documentPickerWasCancelled(_ picker: UIDocumentPickerViewController) {
        print("view was cancelled")
        self.pickerControllerDocument(picker)
    }
}

extension FilePicker: UINavigationControllerDelegate { }
