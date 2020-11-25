//
//  SurveyController.swift
//  WebimClientLibrary
//
//  Created by Nikita Kaberov on 01.08.20.
//  Copyright © 2020 Webim. All rights reserved.
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

/**
 - author:
 Nikita Kaberov
 - copyright:
 2020 Webim
 */

final class SurveyController {
    
    // MARK: - Properties
    private weak var surveyListener: SurveyListener?
    private var survey: Survey?
    private var currentFormPointer = 0
    private var currentQuestionPointer = 0

     // MARK: - Initialization
    init(surveyListener: SurveyListener) {
        self.surveyListener = surveyListener
    }

     // MARK: - Methods
    func set(survey: Survey) {
        self.survey = survey
        setCurrentQuestionPointer()
        surveyListener?.on(survey: survey)
    }

    func getSurvey() -> Survey? {
        return survey
    }

    func getCurrentFormID() -> Int {
        let forms = survey?.getConfig().getDescriptor().getForms()
        return forms?[currentFormPointer].getID() ?? 0
    }

    func getCurrentQuestionPointer() -> Int {
        return currentQuestionPointer
    }

    func nextQuestion() {
        if let question = getCurrentQuestion() {
            surveyListener?.on(nextQuestion: question)
        }
    }

    func cancelSurvey() {
        surveyListener?.onSurveyCancelled()
        survey = nil
        currentFormPointer = 0
        currentQuestionPointer = 0
    }

    private func getCurrentQuestion() -> SurveyQuestion? {
        guard let survey = survey else {
            return nil
        }
        let forms = survey.getConfig().getDescriptor().getForms()
        guard forms.count > currentFormPointer else {
            return nil
        }
        let form = forms[currentFormPointer]

        let questions = form.getQuestions()
        currentQuestionPointer += 1
        if questions.count <= currentQuestionPointer {
            currentQuestionPointer = -1
            currentFormPointer += 1
            return getCurrentQuestion()
        }
        return questions[currentQuestionPointer]
    }

    private func setCurrentQuestionPointer() {
        guard let survey = survey else {
            return
        }
        let forms = survey.getConfig().getDescriptor().getForms()
        let questionInfo = survey.getCurrentQuestionInfo()
        currentQuestionPointer = questionInfo.getQuestionID() - 1

        for (i, form) in forms.enumerated() {
            if form.getID() == questionInfo.getFormID() {
                currentFormPointer = i
                break
            }
        }
    }
}
