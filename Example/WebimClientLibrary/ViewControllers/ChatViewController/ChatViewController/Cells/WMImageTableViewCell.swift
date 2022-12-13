//
//  WMImageMessageCellTableViewCell.swift
//  Webim.Ru
//
//  Created by EVGENII Loshchenko on 11.06.2021.
//  Copyright © 2021 _webim_. All rights reserved.
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
import WebimClientLibrary

class WMImageTableViewCell: WMMessageTableCell, WMFileDownloadProgressListener {
    
    @IBOutlet var imageAspectConstraint: NSLayoutConstraint!
    @IBOutlet var imagePreview: UIImageView!
    @IBOutlet var downloadProcessIndicator: CircleProgressIndicator!
    
    var currentAspectRaito: CGFloat = -1
    var url: URL?
    
    override func setMessage(message: Message, tableView: UITableView) {
        super.setMessage(message: message, tableView: tableView)
        
        self.imagePreview.image = loadingPlaceholderImage
        if let attachment = message.getData()?.getAttachment(), let imageURL = WMDownloadFileManager.shared.urlFromFileInfo(attachment.getFileInfo()) {
            self.url = imageURL
            WMFileDownloadManager.shared.subscribeForImage(url: imageURL, progressListener: self)
        }
    }
    
    func updateAspectConstraint( aspectRatio: CGFloat) {
        if self.currentAspectRaito != aspectRatio {
            self.currentAspectRaito = aspectRatio
            self.imageAspectConstraint.isActive = false
            self.imagePreview.removeConstraint(self.imageAspectConstraint)
            
            if let imageView = self.imagePreview {
                self.imageAspectConstraint = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .width, multiplier: aspectRatio, constant: 0)
            }
            self.imagePreview.addConstraint(self.imageAspectConstraint)
            self.imageAspectConstraint.isActive = true
            if let indexPath = self.tableView?.indexPath(for: self) {
                self.setNeedsLayout()
                self.layoutIfNeeded()
                guard delegate?.canReloadRow() == true else { return }
                self.tableView?.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
    
    func progressChanged(url: URL, progress: Float, image: UIImage?) {
        if url != self.url {
            return
        }
        if let image = image {
            let aspectRatio = image.size.height / image.size.width
            
            self.imagePreview.image = image
            self.downloadProcessIndicator.isHidden = true
            self.updateAspectConstraint(aspectRatio: aspectRatio)
        } else {
            if progress == 1.0 {
                self.downloadProcessIndicator.isHidden = true
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
                    if self.tableView?.visibleCells.contains(self) ?? false {
                        WMFileDownloadManager.shared.subscribeForImage(url: self.url!, progressListener: self)
                    }
                }
            } else {
                if progress != 0.0 {
                    self.downloadProcessIndicator.isHidden = false
                    self.downloadProcessIndicator.updateImageDownloadProgress(progress)
                }
                self.updateAspectConstraint(aspectRatio: 1.0)
            }
        }
    }
    
    @objc func imageViewTapped() {
        self.delegate?.imageViewTapped(message: self.message, image: self.imagePreview.image, url: self.url)
    }
    
    override func initialSetup() -> Bool {
        let setup = super.initialSetup()
        if setup {
            let imageTapGestureRecognizer = UITapGestureRecognizer(
                target: self,
                action: #selector(imageViewTapped)
            )
            self.imagePreview?.gestureRecognizers = nil
            self.imagePreview?.addGestureRecognizer(imageTapGestureRecognizer)
        }
        return setup
    }
    
}
