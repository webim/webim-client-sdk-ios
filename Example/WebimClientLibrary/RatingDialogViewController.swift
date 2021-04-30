//
//  RatingDialogViewController.swift
//  WebimClientLibrary_Example
//
//  Created by Eugene Ilyin on 09.10.2019.
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

import AVFoundation
import Cosmos
import UIKit
import Nuke

class RatingDialogViewController: UIViewController {

    // MARK: - Properties
    var operatorID = String()
    var operatorName = String()
    var operatorAvatarImage = UIImage()
    var operatorAvatarImageURL = String()
    var operatorRating = 0.0
    var viewCenterYPosition = CGFloat()
    
    // MARK: - Subviews
    lazy var blurBackground: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurEffectView
    }()
    lazy var whiteBackground: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20.0
        view.backgroundColor = ratingDialogWhiteBackgroudColour
        return view
    }()
    lazy var operatorAvatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        return imageView
    }()
    lazy var operatorNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textAlignment = .center
        label.textColor = ratingDialogOperatorNameLabelColour
        return label
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17)
        label.textColor = ratingDialogTitleLabelColour
        return label
    }()
    
    lazy var cosmosRatingView: CosmosView = {
        let cosmosView = CosmosView()
        cosmosView.translatesAutoresizingMaskIntoConstraints = false
        cosmosView.settings.fillMode = .full
        cosmosView.settings.starSize = 30
        cosmosView.settings.filledColor = cosmosViewFilledColour
        cosmosView.settings.filledBorderColor = cosmosViewFilledBorderColour
        cosmosView.settings.emptyColor = cosmosViewEmptyColour
        cosmosView.settings.emptyBorderColor = cosmosViewEmptyBorderColour
        cosmosView.settings.emptyBorderWidth = 2
        
        return cosmosView
    }()
    
    lazy var imageDownloadIndicator: CircleProgressIndicator = {
        let downloadIndicator = CircleProgressIndicator()
        downloadIndicator.lineWidth = 1
        downloadIndicator.strokeColor = documentFileStatusPercentageIndicatorColour
        downloadIndicator.isUserInteractionEnabled = false
        downloadIndicator.isHidden = true
        downloadIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        return downloadIndicator
    }()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        AudioServicesPlaySystemSound(1519) // Actuate "Peek" feedback (weak boom)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hideRatingDialogViewController),
            name: .shouldHideRatingDialogViewController,
            object: nil
        )
        
        self.view.backgroundColor = ratingDialogBackgroundColour
        
        setupSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        operatorAvatarImageView.roundCorners(
            [.layerMaxXMaxYCorner,
             .layerMaxXMinYCorner,
             .layerMinXMaxYCorner,
             .layerMinXMinYCorner],
            radius: operatorAvatarImageView.frame.height / 2
        )
        downloadOperatorAvatarIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(
            self,
            name: .shouldHideRatingDialogViewController,
            object: nil
        )
    }
    
    // MARK: - Private methods
    private func setupSubviews() {
        setupBackground()
        
        setupOperatorAvatarImageView()
        setupOperatorNameLabel()
        
        setupCosmosRatingView()
        setupTitleLabel()
    }
    
    private func setupBackground() {
        view.addSubview(blurBackground)
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(hideRatingDialogViewController)
        )
        tapGestureRecognizer.cancelsTouchesInView = false
        tapGestureRecognizer.delegate = self
        view.addGestureRecognizer(tapGestureRecognizer)
        
        view.addSubview(whiteBackground)
        whiteBackground.snp.remakeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(viewCenterYPosition)
            make.height.width.equalTo(200)
        }
    }
    
    @objc
    private func hideRatingDialogViewController() {
        dismiss(animated: false)
        
        // Will not trigger hideOverlayWindow() if there is no keyboard shown. Could fail. For more check todo in ChatTableViewController.swift
        NotificationCenter.default.post(
            name: .shouldHideOverlayWindow,
            object: nil
        )
    }
    
    private func downloadOperatorAvatarIfNeeded() {
        if let avatarURL = URL(string: operatorAvatarImageURL) {
            let request = ImageRequest(url: avatarURL)
            if let image = ImageCache.shared[request] {
                imageDownloadIndicator.isHidden = true
                operatorAvatarImageView.image = image
            } else {
                    operatorAvatarImageView.image = loadingPlaceholderImage

                    Nuke.ImagePipeline.shared.loadImage(
                        with: avatarURL,
                        progress: { _, completed, total in
                            DispatchQueue.global(qos: .userInteractive).async {
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
                        },
                        completion: { _ in
                            DispatchQueue.main.async {
                                self.operatorAvatarImageView.image = ImageCache.shared[request]
                                self.imageDownloadIndicator.isHidden = true
                            }
                        }
                    )
                }
        }
    }
    
    private func setupOperatorAvatarImageView() {
        operatorAvatarImageView.image = operatorAvatarImage
        
        operatorAvatarImageView.addSubview(imageDownloadIndicator)
        imageDownloadIndicator.snp.remakeConstraints { (make) -> Void in
            make.edges.equalToSuperview()
                .inset(5)
        }
        
        whiteBackground.addSubview(operatorAvatarImageView)
        operatorAvatarImageView.snp.remakeConstraints { (make) -> Void in
            make.width.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
                .inset(10)
        }
    }
    
    private func setupOperatorNameLabel() {
        operatorNameLabel.text = operatorName
        
        whiteBackground.addSubview(operatorNameLabel)
        operatorNameLabel.snp.remakeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.top.equalTo(operatorAvatarImageView.snp.bottom)
                .offset(10)
        }
    }
    
    private func setupCosmosRatingView() {
        cosmosRatingView.rating = operatorRating
        cosmosRatingView.didTouchCosmos = { _ in
            AudioServicesPlaySystemSound(1519) // Actuate "Peek" feedback (weak boom)
        }
        cosmosRatingView.didFinishTouchingCosmos = { (rating) -> Void in
            let rating = Int(rating)
            let dictionaryToPost = [self.operatorID: rating]
            NotificationCenter.default.post(
                name: .shouldRateOperator,
                object: nil,
                userInfo: dictionaryToPost
            )
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.hideRatingDialogViewController()
            }
        }
        
        whiteBackground.addSubview(cosmosRatingView)
        cosmosRatingView.snp.remakeConstraints { (make) -> Void in
            make.bottom.equalToSuperview()
                .inset(10)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupTitleLabel() {
        titleLabel.text = "Please rate the agent".localized
        
        whiteBackground.addSubview(titleLabel)
        titleLabel.snp.remakeConstraints { (make) -> Void in
            make.leading.trailing.equalToSuperview()
                .inset(10)
            make.bottom.equalTo(cosmosRatingView.snp.top)
                .offset(-10)
        }
    }
}

extension RatingDialogViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool { !(touch.view?.isDescendant(of: self.whiteBackground) ?? false) }
    
}
