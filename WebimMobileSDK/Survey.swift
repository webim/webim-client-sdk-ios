//
//  Survey.swift
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
 Abstracts a survey.
 - author:
 Nikita Kaberov
 - copyright:
 2020 Webim
 */
public protocol Survey {
    /**
     - returns:
     Config of the survey.
     - author:
     Nikita Kaberov
     - copyright:
     2020 Webim
     */
    func getConfig() -> SurveyConfig
    
    /**
     Every survey can be uniquefied by its ID.
     - returns:
     Unique ID of the survey.
     - author:
     Nikita Kaberov
     - copyright:
     2020 Webim
     */
    func getID() -> String
    
    /**
     - returns:
     Current question information of the survey.
     - author:
     Nikita Kaberov
     - copyright:
     2020 Webim
     */
    func getCurrentQuestionInfo() -> SurveyCurrentQuestionInfo
}

/**
Abstracts a survey config.
- author:
Nikita Kaberov
- copyright:
2020 Webim
*/
public protocol SurveyConfig {
    /**
     - returns:
     Unique ID of the survey config.
     - author:
     Nikita Kaberov
     - copyright:
     2020 Webim
     */
    func getID() -> Int

    /**
     - returns:
     Descriptor of the survey config.
     - author:
     Nikita Kaberov
     - copyright:
     2020 Webim
     */
    func getDescriptor() -> SyrveyDescriptor

    /**
     - returns:
     Version of the survey config.
     - author:
     Nikita Kaberov
     - copyright:
     2020 Webim
     */
    func getVersion() -> String
}

/**
Abstracts a survey descriptor.
- author:
Nikita Kaberov
- copyright:
2020 Webim
*/
public protocol SyrveyDescriptor {
    /**
     - returns:
     Array of forms.
     - author:
     Nikita Kaberov
     - copyright:
     2020 Webim
     */
    func getForms() -> [SurveyForm]
}

/**
Abstracts a survey form.
- author:
Nikita Kaberov
- copyright:
2020 Webim
*/
public protocol SurveyForm {
    /**
     - returns:
     Unique ID of the survey form.
     - author:
     Nikita Kaberov
     - copyright:
     2020 Webim
     */
    func getID() -> Int
    
    /**
     - returns:
     Array of questions of the survey form.
     - author:
     Nikita Kaberov
     - copyright:
     2020 Webim
     */
    func getQuestions() -> [SurveyQuestion]
 }

/**
Abstracts a survey question.
- author:
Nikita Kaberov
- copyright:
2020 Webim
*/
public protocol SurveyQuestion {
    /**
     - returns:
     Type of the survey question.
     - author:
     Nikita Kaberov
     - copyright:
     2020 Webim
     */
    func getType() -> SurveyType

    /**
     - returns:
     Text of the survey question.
     - author:
     Nikita Kaberov
     - copyright:
     2020 Webim
     */
    func getText() -> String
    
    /**
     - returns:
     Array of options of the survey question.
     - author:
     Nikita Kaberov
     - copyright:
     2020 Webim
     */
    func getOptions() -> [String]?
}

/**
 Supported survey question types.
 - seealso:
 `SurveyQuestion.getType()`
 - author:
 Nikita Kaberov
 - copyright:
 2020 Webim
 */
public enum SurveyType {
    /**
     User need to rate something or somebody.
     - author:
     Nikita Kaberov
     - copyright:
     2020 Webim
     */
    case stars
    
    /**
     User need to choose the option.
     - author:
     Nikita Kaberov
     - copyright:
     2020 Webim
     */
    case radio
    
    /**
     User need to write comment.
     - author:
     Nikita Kaberov
     - copyright:
     2020 Webim
     */
    case comment
}

/**
Abstracts a survey current question information.
- author:
Nikita Kaberov
- copyright:
2020 Webim
*/
public protocol SurveyCurrentQuestionInfo {
    /**
     - returns:
     Unique ID of the form of the survey current question info.
     - author:
     Nikita Kaberov
     - copyright:
     2020 Webim
     */
    func getFormID() -> Int
    
    /**
     - returns:
     Unique ID of the question of the survey current question info.
     - author:
     Nikita Kaberov
     - copyright:
     2020 Webim
     */
    func getQuestionID() -> Int
}
