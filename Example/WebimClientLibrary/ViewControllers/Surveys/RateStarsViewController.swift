//
//  RateStarsViewController.swift
//  WebimClientLibrary_Example
//
//  Created by Возлеев Юрий on 04.02.2021.
//  Copyright © 2021 Webim. All rights reserved.
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

protocol RateStarsViewControllerDelegate: AnyObject {
    
    func rateOperator(operatorID: String, rating: Int)
}

class RateStarsViewController: WMSurveyViewController {
    
    // MARK: - Init Properties
    weak var rateOperatorDelegate: RateStarsViewControllerDelegate?
    var operatorId = String()
    var operatorRating = 0.0
    var isSurvey = false
    var descriptionText: String?

    // MARK: - IBOutlets
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var containerView: UIView!
    
    // MARK: - Subviews
    private var cosmosRatingView: CosmosView = RateStarsViewController.configureCosmosView()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }
    
    private func setupSubviews() {
        
        if self.isSurvey {
            self.titleLabel.alpha = 0
        }
        descriptionLabel.text = isSurvey ? descriptionText : "Please rate the overall impression of the consultation".localized
        
        self.disableSendButton()
        
        cosmosRatingView.rating = operatorRating
        
        self.cosmosRatingView.didFinishTouchingCosmos = { (rating) -> Void in
            self.operatorRating = rating
            self.enableSendButton()
        }
        containerView.addSubview(cosmosRatingView)

    }

    @IBAction func sendRate(_ sender: Any) {
        let rating = Int(operatorRating)
        
        if isSurvey {
            self.delegate?.sendSurveyAnswer("\(rating)")
        } else {
            self.rateOperatorDelegate?.rateOperator(operatorID: self.operatorId, rating: rating)
        }
        
        self.close(nil)
    }
    
    private static func configureCosmosView() -> CosmosView {
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
    }
}
