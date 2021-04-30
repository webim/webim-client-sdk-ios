//
//  ImageConstants.swift
//  WebimClientLibrary_Example
//
//  Created by Eugene Ilyin on 15.10.2019.
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

import Foundation
import UIKit

// ChatViewController.swift
let closeButtonImage = #imageLiteral(resourceName: "CloseButton")
let fileButtonImage = #imageLiteral(resourceName: "AttachmentButton")
let loadingPlaceholderImage: UIImage! = UIImage(named: "ImagePlaceholder")
let navigationBarTitleImageViewImage = #imageLiteral(resourceName: "LogoWebimNavigationBar_dark")
let scrollButtonImage = #imageLiteral(resourceName: "SendMessageButton").flipImage(.vertically)
let textInputButtonImage = #imageLiteral(resourceName: "SendMessageButton")

// ChatTableViewController.swift
let documentFileStatusImageViewImage = #imageLiteral(resourceName: "FileDownloadError")
let leadingSwipeActionImage =
    UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ?
        #imageLiteral(resourceName: "ReplyCircleToTheLeft") :
        #imageLiteral(resourceName: "ReplyCircleToTheLeft").flipImage(.horizontally)
let trailingSwipeActionImage =
    UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ?
        #imageLiteral(resourceName: "ReplyCircleToTheLeft").flipImage(.horizontally) :
        #imageLiteral(resourceName: "ReplyCircleToTheLeft")

// ImageViewController.swift
let saveImageButtonImage = #imageLiteral(resourceName: "ImageDownload")

// FlexibleTableViewCell.swift
let documentFileStatusButtonDownloadOperator = #imageLiteral(resourceName: "FileDownloadButtonOperator")
let documentFileStatusButtonDownloadVisitor = #imageLiteral(resourceName: "FileDownloadButtonVisitor")
let documentFileStatusButtonDownloadError = #imageLiteral(resourceName: "FileDownloadError")
let documentFileStatusButtonDownloadSuccessOperator = #imageLiteral(resourceName: "FileDownloadSuccessOperator")
let documentFileStatusButtonDownloadSuccessVisitor = #imageLiteral(resourceName: "FIleDownloadSeccessVisitor")
let documentFileStatusButtonUploadVisitor = #imageLiteral(resourceName: "FileUploadButtonVisitor.pdf")
let userAvatarImagePlaceholder = #imageLiteral(resourceName: "HardcodedVisitorAvatar")
let messageStatusImageViewImageSent = #imageLiteral(resourceName: "Sent")
let messageStatusImageViewImageRead = #imageLiteral(resourceName: "ReadByOperator")

// PopupActionTableViewCell.swift
let replyImage = #imageLiteral(resourceName: "ActionReply")
let copyImage = #imageLiteral(resourceName: "ActionCopy")
let editImage = #imageLiteral(resourceName: "ActionEdit")
let deleteImage = #imageLiteral(resourceName: "ActionDelete").colour(actionColourDelete)
