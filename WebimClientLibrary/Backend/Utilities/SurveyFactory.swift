//
//  SurveyFactory.swift
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
 Mapper class that is responsible for converting internal survey model objects to public ones.
 - author:
 Nikita Kaberov
 - copyright:
 2018 Webim
 */
final class SurveyFactory {
    
    // MARK: - Methods
    func createSurveyFrom(surveyItem: SurveyItem) -> Survey? {
        guard let configItem = surveyItem.getConfig(),
              let config = createConfigFrom(configItem: configItem),
              let currentQuestionInfoItem = surveyItem.getCurrentQuestionInfo(),
              let currentQuestionInfo = createCurrentQuestionInfoFrom(currentQuestionInfoItem: currentQuestionInfoItem),
              let id = surveyItem.getID() else {
            return nil
        }
        return SurveyImpl(config: config,
                          currentQuestionInfo: currentQuestionInfo,
                          id: id)
    }

    private func createConfigFrom(configItem: ConfigItem) -> SurveyConfig? {
        guard let descriptorItem = configItem.getDescriptor(),
            let descriptor = createDescriptorFrom(descriptorItem: descriptorItem),
            let id = configItem.getID(),
            let version = configItem.getVersion() else {
                return nil
        }
        return ConfigImpl(id: id,
                          descriptor: descriptor,
                          version: version)
    }

    private func createDescriptorFrom(descriptorItem: DescriptorItem) -> SyrveyDescriptor? {
        var forms = [SurveyForm]()
        guard let formItems = descriptorItem.getForms() else {
            return nil
        }
        for form in formItems {
            if let formID = form.getID(),
                let questionItems = form.getQuestions() {
                let formImpl = FormImpl(id: formID, questions: createQuestionsFrom(questionItems: questionItems))
                forms.append(formImpl)
            }
        }
        return DescriptorImpl(forms: forms)
    }

    private func createQuestionsFrom(questionItems: [QuestionItem]) -> [SurveyQuestion] {
        var questions = [SurveyQuestion]()
        for questionItem in questionItems {
            if let text = questionItem.getText() {
                let questionImpl = QuestionImpl(type: toQuestionType(questionKind: questionItem.getType()),
                                                text: text,
                                                options: questionItem.getOptions())
                questions.append(questionImpl)
            }
        }
        return questions
    }
    
    private func toQuestionType(questionKind: QuestionItem.QuestionKind?) -> SurveyType {
        switch questionKind {
        case .stars:
            return .stars
        case .radio:
            return .radio
        case .comment,
             .none:
            return .comment
        }
    }
    
    private func createCurrentQuestionInfoFrom(currentQuestionInfoItem: CurrentQuestionInfoItem) -> SurveyCurrentQuestionInfo? {
        guard let formID = currentQuestionInfoItem.getFormID(),
              let questionID = currentQuestionInfoItem.getQuestionID() else {
            return nil
        }
        return CurrentQuestionInfoImpl(formID: formID,
                                       questionID: questionID)
    }
    
}
