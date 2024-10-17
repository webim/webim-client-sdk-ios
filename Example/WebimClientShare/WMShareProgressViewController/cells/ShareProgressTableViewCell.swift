//
//  ShareProgressTableViewCell.swift
//  WebimClientShare
//
//  Created by Anna Frolova on 11.03.2024.
//  Copyright © 2024 Webim. All rights reserved.
//

import UIKit
import WebimMobileSDK

class ShareProgressTableViewCell: UITableViewCell {
    @IBOutlet private var progressIndicator: CircleProgressIndicator!
    @IBOutlet private var fileNameLabel: UILabel!
    @IBOutlet private var progressInfoLabel: UILabel!
    @IBOutlet private var fileStateImageView: UIImageView!

    func setProgress(_ progress: Float) {
        progressIndicator.setProgressWithAnimation(duration: 0.5, value: progress)
    }

    func setFileName(_ fileName: String) {
        fileNameLabel.text = fileName
    }

    func setProgressInfo(_ progressInfo: String) {
        progressInfoLabel.text = progressInfo
    }

    func setState(_ state: MessageSendStatus) {
        switch state {
        case .sending:
            progressIndicator.isHidden = false
            fileStateImageView.isHidden = true
            fileNameLabel.textColor = quoteBodyLabelColourVisitor
            fileStateImageView.image = nil
            progressIndicator.enableRotationAnimation()
            progressIndicator?.setProgressWithAnimation(
                duration: 0.01,
                value: 0.5
            )
        case .sent:
            progressIndicator.isHidden = true
            fileStateImageView.isHidden = false
            fileNameLabel.textColor = webimCyan
            fileStateImageView.image = #imageLiteral(resourceName: "FileDownloadSuccessOperator")
        default:
            progressIndicator.isHidden = true
            fileStateImageView.isHidden = false
            fileNameLabel.textColor = wmCoral
            fileStateImageView.image = UIImage(named: "FileDownloadError")!
        }
    }
    func setupIndicator() {
        progressIndicator?.setDefaultSetup()
    }
}
