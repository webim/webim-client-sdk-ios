//
//  ChatTableViewController+SurveyListener.swift
//  WebimClientLibrary_Example
//
//  Created by EVGENII Loshchenko on 06.04.2021.
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

import Foundation
import WebimClientLibrary

// MARK: - WEBIM: SurveyListener
extension ChatTableViewController: SurveyListener {
    
    func on(survey: Survey) {
        surveyCounter = 0
        for form in survey.getConfig().getDescriptor().getForms() {
            surveyCounter += form.getQuestions().count
        }
    }

    func on(nextQuestion: SurveyQuestion) {
        DispatchQueue.main.async {
            if self.rateStarsViewController != nil {
                self.delayedSurvayQuestion = nextQuestion
                return
            }
            self.delayedSurvayQuestion = nil
            self.surveyCounter -= 1
            let description = nextQuestion.getText()
            
            let operatorId = ""
            switch nextQuestion.getType() {
            case .comment:
                self.showSurveyCommentDialog(description: description)
            case .radio:
                self.showSurveyRadioButtonDialog(description: description, points: nextQuestion.getOptions() ?? [])
            case .stars:
                self.showRateStars(operatorId: operatorId, isSurvey: true, description: description)
            }
        }
    }

    func onSurveyCancelled() {
        surveyCounter = -1
        self.surveyCommentViewController?.close(nil)
        self.rateStarsViewController?.close(nil)
        self.surveyRadioButtonViewController?.close(nil)
        
        self.rateStarsViewController = nil
        self.surveyRadioButtonViewController = nil
        self.surveyCommentViewController = nil
        
        self.delayedSurvayQuestion = nil
    }
}

// MARK: - WEBIM: Survey
extension ChatTableViewController {
    
    func showRateOperatorDialog(operatorId: String?) {
        if let operatorId = operatorId {
            self.showRateStars(operatorId: operatorId, isSurvey: false, description: "")
        }
    }
    
    func showRateOperatorDialog() {
        showRateOperatorDialog(operatorId: currentOperatorId())
    }
    
    func currentOperatorId() -> String? {
        if let operatorId = WebimServiceController.currentSession.getCurrentOperator()?.getID() {
            return operatorId
        }
        
        for index in stride(from: self.chatMessages.count - 1, to: 0, by: -1) {
            let operatorId = self.chatMessages[index].getOperatorID()
            if operatorId != nil {
                return operatorId
            }
        }
        return nil
    }
    
    func showRateStarsDialog(description: String) {
        
        self.showRateStars(operatorId: "", isSurvey: true, description: description)
    }
    
    private func showRateStars(operatorId: String, isSurvey: Bool, description: String) {
        DispatchQueue.main.async {
            
            let vc = RateStarsViewController()
            vc.delegate = self
            vc.rateOperatorDelegate = self
            self.rateStarsViewController = vc
            vc.operatorId = operatorId
            vc.isSurvey = isSurvey
            vc.descriptionText = description
            vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            vc.operatorRating = Double(WebimServiceController.shared.currentSession().getLastRatingOfOperatorWith(id: operatorId))
            self.present(vc, animated: false, completion: nil)
        }
    }
    
    func showSurveyCommentDialog(description: String) {
        DispatchQueue.main.async {
            AppDelegate.keyboardHidden(true)
            
            let vc = SurveyCommentViewController()
            self.surveyCommentViewController = vc
            vc.descriptionText = description
            vc.delegate = self
            vc.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            self.present(vc, animated: false, completion: nil)
        }
    }
    
    func showSurveyRadioButtonDialog(description: String, points: [String]) {
        
        DispatchQueue.main.async {
            AppDelegate.keyboardHidden(true)
            
            let vc = SurveyRadioButtonViewController()
            self.surveyRadioButtonViewController = vc
            vc.descriptionText = description
            vc.points = points
            vc.delegate = self
            vc.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            self.present(vc, animated: false, completion: nil)
            
        }
    }
}

extension ChatTableViewController: RateStarsViewControllerDelegate, WMSurveyViewControllerDelegate {
    func rateOperator(operatorID: String, rating: Int) {
        WebimServiceController.currentSession.rateOperator(
            withID: operatorID,
            byRating: rating,
            completionHandler: self
        )
        if self.delayedSurvayQuestion == nil { // no surveys after operator rate requests
            self.chatViewController?.thanksView.showAlert()
        }
    }
    
    @objc
    func sendSurveyAnswer(_ surveyAnswer: String) {
        WebimServiceController.currentSession.send(
            surveyAnswer: surveyAnswer,
            completionHandler: self
        )
        
        if surveyCounter == 0 {
            self.chatViewController?.thanksView.showAlert()
            surveyCounter = -1
        }
    }
    
    func surveyViewControllerClosed() {
        self.rateStarsViewController = nil
        if let delayedQuestion = self.delayedSurvayQuestion {
            self.on(nextQuestion: delayedQuestion)
        }
    }
}

// MARK: - WEBIM: CompletionHandlers
extension ChatTableViewController: RateOperatorCompletionHandler, SendSurveyAnswerCompletionHandler {
    
    func onSuccess() {
        // Workaround needed since operator dialog dismissed after a small delay
    }
    
    func onFailure(error: RateOperatorError) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.41) {
            var message = String()
            switch error {
            case .noChat:
                message = "This chat does not exist".localized
            case .wrongOperatorId:
                message = "This agent not in the current chat".localized
            case .noteIsTooLong:
                message = "Note for rate is too long".localized
            }
            
            self.alertDialogHandler.showDialog(
                withMessage: message,
                title: "Operator rating failed".localized
            )
        }
    }
    
    // SendSurveyAnswerCompletionHandler
    func onFailure(error: SendSurveyAnswerError) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.41) {
            var message = String()
            switch error {
            case .incorrectRadioValue:
                message = "Incorrect radio value".localized
            case .incorrectStarsValue:
                message = "Incorrect stars value".localized
            case .incorrectSurveyID:
                message = "Incorrect survey ID".localized
            case .maxCommentLength_exceeded:
                message = "Comment is too long".localized
            case .noCurrentSurvey:
                message = "No current survey".localized
            case .questionNotFound:
                message = "Question not found".localized
            case .surveyDisabled:
                message = "Survey disabled".localized
            case .unknown:
                message = "Unknown error".localized
            }
            
            self.alertDialogHandler.showDialog(
                withMessage: message,
                title: "Failed to send survey answer".localized
            )
        }
    }
}
