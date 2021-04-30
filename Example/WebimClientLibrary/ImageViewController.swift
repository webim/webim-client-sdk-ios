//
//  ImageViewController.swift
//  WebimClientLibrary_Example
//
//  Created by Eugene Ilyin on 29/08/2019.
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
import Nuke

class ImageViewController: UIViewController {

    // MARK: - Properties
    var selectedImage: UIImage?
    var selectedImageURL: URL?
    
    // MARK: - Private properties
    private lazy var alertDialogHandler = UIAlertHandler(delegate: self)
    private lazy var imageDownloadIndicator: CircleProgressIndicator = {
        let indicator = CircleProgressIndicator()
        indicator.lineWidth = 1
        indicator.strokeColor = documentFileStatusPercentageIndicatorColour
        indicator.isUserInteractionEnabled = false
        indicator.isHidden = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Outlets
    @IBOutlet var imageView: UIImageView!
    
    // MARK: - View Life Cycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.global(qos: .userInteractive).async {
            self.reloadImageIfNeed()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNewTopbar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItem()
        
        imageView.isUserInteractionEnabled = true
        
        if let imageToLoad = selectedImage {
            imageView.image = imageToLoad
        }
        
        addGestures()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        setOldTopBar()
    }
    
    // MARK: - Private methods
    private func setupNavigationItem() {
        let rightButton = UIButton(type: .system)
        rightButton.frame = CGRect(x: 0.0, y: 0.0, width: 20.0, height: 20.0)
        rightButton.setBackgroundImage(saveImageButtonImage, for: .normal)
        rightButton.addTarget(
            self,
            action: #selector(saveButtonTapped),
            for: .touchUpInside
        )
        
        rightButton.snp.remakeConstraints { (make) -> Void in
            make.height.width.equalTo(25.0)
        }
        
        let rightBarButton = UIBarButtonItem(customView: rightButton)
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    private func reloadImageIfNeed() {
        guard selectedImage == nil,
            let url = selectedImageURL else { return }
        let request = ImageRequest(url: url)

        if let image = ImageCache.shared[request] {
            self.selectedImage = image
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        } else {
            DispatchQueue.main.async {
                self.imageView.image = loadingPlaceholderImage
                self.imageView.addSubview(self.imageDownloadIndicator)
                self.imageDownloadIndicator.snp.remakeConstraints { (make) -> Void in
                    make.centerX.equalToSuperview()
                    make.centerY.equalToSuperview()
                    make.height.equalTo(45)
                    make.width.equalTo(45)
                }
                
                Nuke.ImagePipeline.shared.loadImage(
                    with: url,
                    progress: { _, completed, total in
                        DispatchQueue.global(qos: .userInteractive).async {
                            self.updateImageDownloadProgress(
                                completed: completed,
                                total: total
                            )
                        }
                    },
                    completion: { _ in
                        DispatchQueue.main.async {
                            self.selectedImage = ImageCache.shared[request]
                            self.imageView.image = ImageCache.shared[request]
                            self.imageDownloadIndicator.isHidden = true
                        }
                    }
                )
            }
        }
    }
    
    @objc
    private func saveButtonTapped(sender: UIBarButtonItem) {
        guard let imageToSave = selectedImage else { return }
        
        UIImageWriteToSavedPhotosAlbum(
            imageToSave,
            self,
            #selector(image(_:didFinishSavingWithError:contextInfo:)),
            nil
        )
    }
    
    @objc
    private func image(
        _ image: UIImage,
        didFinishSavingWithError error: NSError?,
        contextInfo: UnsafeRawPointer
    ) {
        if let error = error {
            // Save error
            alertDialogHandler.showImageSavingFailureDialog(withError: error)
        } else {
            alertDialogHandler.showImageSavingSuccessDialog()
        }
    }
    
    private func addGestures() {
        let pan = UIPanGestureRecognizer(
            target: self,
            action: #selector(panGesture)
        )
        pan.minimumNumberOfTouches = 1
        pan.maximumNumberOfTouches = 1
        imageView.addGestureRecognizer(pan)
        
        let pinch = UIPinchGestureRecognizer(
            target: self,
            action: #selector(pinchGesture)
        )
        imageView.addGestureRecognizer(pinch)
        
        let rotate = UIRotationGestureRecognizer(
            target: self,
            action: #selector(rotateGesture)
        )
        imageView.addGestureRecognizer(rotate)
    }
    
    @objc
    private func panGesture(sender: UIPanGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            
            guard let view = sender.view else { return }
            let translation = sender.translation(in: view.superview)
            let transform = CGAffineTransform(
                translationX: translation.x,
                y: translation.y
            )
            imageView.transform = transform
            
        } else {
            UIView.animate(
                withDuration: 0.5,
                animations: {
                    self.imageView.transform = CGAffineTransform.identity
                }
            )
            
            guard navigationController?.navigationBar.isHidden == false else { return }
            let velocity = sender.velocity(in: view)
            
            guard velocity.y >= 1500 else { return }
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc
    private func pinchGesture(sender: UIPinchGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            guard let view = sender.view else { return }
        
            let pinchCenter = CGPoint(
                x: sender.location(in: view).x - view.bounds.midX,
                y: sender.location(in: view).y - view.bounds.midY
            )
            
            let transform = view.transform
                .translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                .scaledBy(x: sender.scale, y: sender.scale)
                .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
            
            let currentScale = imageView.frame.size.width / imageView.bounds.size.width
            var newScale = currentScale * sender.scale
            
            if newScale < 1 {
                newScale = 1
                let transform = CGAffineTransform(scaleX: newScale,
                                                  y: newScale)
                imageView.transform = transform
                sender.scale = 1
            } else {
                view.transform = transform
                sender.scale = 1
            }
            
        } else
            if sender.state == .ended ||
            sender.state == .failed ||
            sender.state == .cancelled {
            
            UIView.animate(
                withDuration: 0.5,
                animations: {
                    self.imageView.transform = CGAffineTransform.identity
                }
            )
        }
    }
    
    @objc
    private func rotateGesture (sender: UIRotationGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            guard sender.view != nil else { return }
            let transform = CGAffineTransform(rotationAngle: sender.rotation)
            
            imageView.transform = transform
        } else
            if sender.state == .ended ||
                sender.state == .failed ||
                sender.state == .cancelled {
            
            UIView.animate(
                withDuration: 0.5,
                animations: {
                    self.imageView.transform = CGAffineTransform.identity
                }
            )
    
        }
    }
    
    private func setNewTopbar() {
        setTopBar(
            hidesBarsOnTap: true,
            isEnabled: false,
            isTranslucent: true,
            barTintColor: topBarTintColourClear
        )
        
    }
    
    private func setOldTopBar() {
        setTopBar(
            hidesBarsOnTap: false,
            isEnabled: true,
            isTranslucent: false,
            barTintColor: topBarTintColourDefault
        )
    }
    
    private func setTopBar(
        hidesBarsOnTap: Bool,
        isEnabled: Bool,
        isTranslucent: Bool,
        barTintColor: UIColor
    ) {
        navigationController?.hidesBarsOnTap = hidesBarsOnTap
        navigationController?.interactivePopGestureRecognizer?.isEnabled = isEnabled
        navigationController?.navigationBar.isTranslucent = isTranslucent
        navigationController?.navigationBar.barTintColor = barTintColor
    }
    
    private func updateImageDownloadProgress(completed: Int64, total: Int64) {
        let progress = Float(completed) / Float(total)
        DispatchQueue.main.async {
            if self.imageDownloadIndicator.isHidden {
                self.imageDownloadIndicator.isHidden = false
                self.imageDownloadIndicator.enableRotationAnimation()
            }
            self.imageDownloadIndicator.setProgressWithAnimation(
                duration: 0.1,
                value: progress
            )
        }
    }
}
