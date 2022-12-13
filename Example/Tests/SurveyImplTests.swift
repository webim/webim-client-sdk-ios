//
//  SurveyImplTests.swift
//  WebimClientLibrary_Tests
//
//  Created by Аслан Кутумбаев on 30.08.2022.
//  Copyright © 2022 Webim. All rights reserved.
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
import XCTest
@testable import WebimClientLibrary

class SurveyImplTests: XCTestCase {
    var sut: SurveyImpl!
    var config: SurveyConfig!
    var questionInfo: SurveyCurrentQuestionInfo!
    var id: String!

    override func setUp() {
        super.setUp()
        let question = QuestionImpl(type: .comment, text: "question", options: nil)
        let form = FormImpl(id: 15, questions: [question,question,question])
        let descriptor = DescriptorImpl(forms: [form,form,form,form])

        config = ConfigImpl(id: 123,
                                descriptor: descriptor,
                                version: "version")
        questionInfo = CurrentQuestionInfoImpl(formID: 66, questionID: 99)
        id = "555"


        sut = SurveyImpl(config: config,
                         currentQuestionInfo: questionInfo,
                         id: id)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testInit() {
        XCTAssertEqual(sut.getID(), id)
        XCTAssertEqual(sut.getConfig().getID(), config.getID())
        XCTAssertEqual(sut.getCurrentQuestionInfo().getQuestionID(), questionInfo.getQuestionID())
    }
}

class ConfigImplTests: XCTestCase {
    var sut: SurveyConfig!

    override func setUp() {
        super.setUp()
        let question = QuestionImpl(type: .comment, text: "question", options: nil)
        let form = FormImpl(id: 15, questions: [question,question,question])
        let descriptor = DescriptorImpl(forms: [form,form,form,form])

        sut = ConfigImpl(id: 123,
                            descriptor: descriptor,
                            version: "version")
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testInit() {
        let expectedId = 123
        let expectedFormsCount = 4
        let expectedVesion = "version"

        XCTAssertEqual(sut.getID(), expectedId)
        XCTAssertEqual(sut.getDescriptor().getForms().count, expectedFormsCount)
        XCTAssertEqual(sut.getVersion(), expectedVesion)
    }
}

class DescriptorImplTests: XCTestCase {
    var sut: SyrveyDescriptor!

    override func setUp() {
        super.setUp()
        let question = QuestionImpl(type: .comment, text: "question", options: nil)
        let form = FormImpl(id: 15, questions: [question,question,question])
        sut = DescriptorImpl(forms: [form,form,form,form])
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testInit() {
        let expectedFormsCount = 4

        XCTAssertEqual(sut.getForms().count, expectedFormsCount)
    }
}

class FormImplTests: XCTestCase {
    var sut: SurveyForm!

    override func setUp() {
        super.setUp()
        let question = QuestionImpl(type: .comment, text: "question", options: nil)
        sut = FormImpl(id: 15, questions: [question,question,question])
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testInit() {
        let expectedId = 15
        let expectedQuestionCount = 3

        XCTAssertEqual(sut.getID(), expectedId)
        XCTAssertEqual(sut.getQuestions().count, expectedQuestionCount)
    }
}

class QuestionImplTests: XCTestCase {
    var sut: SurveyQuestion!

    override func setUp() {
        super.setUp()
        sut = QuestionImpl(type: .comment, text: "question", options: ["opt1", "opt2"])
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testInit() {
        let expectedType = SurveyType.comment
        let expectedText = "question"
        let expectedOptionsCount = 2

        XCTAssertEqual(sut.getType(), expectedType)
        XCTAssertEqual(sut.getText(), expectedText)
        XCTAssertNotNil(sut.getOptions())
        XCTAssertEqual(sut.getOptions()!.count, expectedOptionsCount)
    }
}
