//
//  SurveyImpl.swift
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
 Internal surveys representasion.
 - author:
 Nikita Kaberov
 - copyright:
 2020 Webim
 */
class SurveyImpl {
    private let config: SurveyConfig
    private let currentQuestionInfo:  SurveyCurrentQuestionInfo
    private let id: String

    init(config: SurveyConfig, currentQuestionInfo: SurveyCurrentQuestionInfo, id: String) {
        self.config = config
        self.currentQuestionInfo = currentQuestionInfo
        self.id = id
    }
}

extension SurveyImpl: Survey {
    func getConfig() -> SurveyConfig {
        return config
    }
    
    func getCurrentQuestionInfo() -> SurveyCurrentQuestionInfo {
        return currentQuestionInfo
    }

    func getID() -> String {
        return id
    }
}

class ConfigImpl {
    private let id: Int
    private let descriptor: SyrveyDescriptor
    private let version: String
    
    init(id: Int, descriptor: SyrveyDescriptor, version: String) {
        self.id = id
        self.descriptor = descriptor
        self.version = version
    }
}

extension ConfigImpl: SurveyConfig {
    func getID() -> Int {
        return id
    }

    func getDescriptor() -> SyrveyDescriptor {
        return descriptor
    }
    
    func getVersion() -> String {
        return version
    }
}

class DescriptorImpl {
    private let forms: [SurveyForm]
    
    init(forms: [SurveyForm]) {
        self.forms = forms
    }
}

extension DescriptorImpl: SyrveyDescriptor {
    func getForms() -> [SurveyForm] {
        return forms
    }
}

class FormImpl {
    private let id: Int
    private let questions: [SurveyQuestion]
    
    init(id: Int, questions: [SurveyQuestion]) {
        self.id = id
        self.questions = questions
    }
}

extension FormImpl: SurveyForm {
    func getID() -> Int {
        return id
    }
    
    func getQuestions() -> [SurveyQuestion] {
        return questions
    }
}

class QuestionImpl {
    private let type: SurveyType
    private let text: String
    private let options: [String]?
    
    init(type: SurveyType, text: String, options: [String]?) {
        self.type = type
        self.text = text
        self.options = options
    }
}

extension QuestionImpl: SurveyQuestion {
    func getType() -> SurveyType {
        return type
    }
    
    func getText() -> String {
        return text
    }
    
    func getOptions() -> [String]? {
        return options
    }
}

class CurrentQuestionInfoImpl {
    private let formID: Int
    private let questionID: Int
    
    init(formID: Int, questionID: Int) {
        self.formID = formID
        self.questionID = questionID
    }
}

extension CurrentQuestionInfoImpl: SurveyCurrentQuestionInfo {
    func getFormID() -> Int {
        return formID
    }
    
    func getQuestionID() -> Int {
        return questionID
    }
    
    
}
