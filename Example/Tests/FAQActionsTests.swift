//
//  FAQActionsTests.swift
//  WebimClientLibrary_Tests
//
//  Created by Аслан Кутумбаев on 23.08.2022.
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
@testable import WebimMobileSDK

class FAQActionsTests: XCTestCase {


    let faqDestroyer = FAQDestroyer()
    let queue = DispatchQueue.global()
    let baseURL = "https://wmtest6.webim.ru"
    var completionHandlerExecutor: ExecIfNotDestroyedFAQHandlerExecutor!
    var faqRequestLoopMock: FAQRequestLoopMock!
    var sut: FAQActions!


    override func setUp() {
        super.setUp()
        completionHandlerExecutor = ExecIfNotDestroyedFAQHandlerExecutor(faqDestroyer: faqDestroyer, queue: queue)
        faqRequestLoopMock = FAQRequestLoopMock(completionHandlerExecutor: completionHandlerExecutor, baseURL: baseURL)
        sut = FAQActions(faqRequestLoop: faqRequestLoopMock)
    }

    override func tearDown() {
        sut = nil
        faqRequestLoopMock = nil
        completionHandlerExecutor = nil
        super.tearDown()
    }

    func testGetItemMethodCall() {
        sut.getItem(itemId: "some") { _ in }

        XCTAssertTrue(faqRequestLoopMock.executeCalled)
    }

    func testGetItemValidURL() {
        sut.getItem(itemId: "some") { _ in }
        let expectedURLString = baseURL + FAQActions.ServerPathSuffix.item.rawValue

        XCTAssertEqual(faqRequestLoopMock.webimRequest?.getBaseURLString(), expectedURLString)
    }

    func testGetCategoryMethodCall() {
        sut.getCategory(categoryId: "some") { _ in }

        XCTAssertTrue(faqRequestLoopMock.executeCalled)
    }

    func testGetCategoryValidURL() {
        sut.getCategory(categoryId: "some") { _ in }
        let expectedURLString = baseURL + FAQActions.ServerPathSuffix.category.rawValue

        XCTAssertEqual(faqRequestLoopMock.webimRequest?.getBaseURLString(), expectedURLString)
    }

    func testGetCategoriesForMethodCall() {
        sut.getCategoriesFor(application: "some", language: "some", departmentKey: "some") { _ in }

        XCTAssertTrue(faqRequestLoopMock.executeCalled)
    }

    func testGetCategoriesForValidURL() {
        sut.getCategoriesFor(application: "some", language: "some", departmentKey: "some") { _ in }
        let expectedURL =  baseURL + FAQActions.ServerPathSuffix.categories.rawValue

        XCTAssertEqual(faqRequestLoopMock.webimRequest?.getBaseURLString(), expectedURL)
    }

    func testGetStructureMethodCall() {
        sut.getStructure(categoryId: "some") { _ in }

        XCTAssertTrue(faqRequestLoopMock.executeCalled)
    }

    func testGetStructureValidURL() {
        sut.getStructure(categoryId: "some") { _ in }
        let expectedURL =  baseURL + FAQActions.ServerPathSuffix.structure.rawValue

        XCTAssertEqual(faqRequestLoopMock.webimRequest?.getBaseURLString(), expectedURL)
    }

    func testSearchMethodCall() {
        sut.search(query: "some", categoryId: "some", limit: .zero) { _ in }

        XCTAssertTrue(faqRequestLoopMock.executeCalled)
    }

    func testSearchValidURL() {
        sut.search(query: "some", categoryId: "some", limit: .zero) { _ in }
        let expectedURL =  baseURL + FAQActions.ServerPathSuffix.search.rawValue

        XCTAssertEqual(faqRequestLoopMock.webimRequest?.getBaseURLString(), expectedURL)
    }

    func testLikeMethodCall() {
        sut.like(itemId: "some") { _ in }

        XCTAssertTrue(faqRequestLoopMock.executeCalled)
    }

    func testLikeValidURL() {
        sut.like(itemId: "some") { _ in }
        let expectedURL =  baseURL + FAQActions.ServerPathSuffix.like.rawValue

        XCTAssertEqual(faqRequestLoopMock.webimRequest?.getBaseURLString(), expectedURL)
    }

    func testDislikeMethodCall() {
        sut.dislike(itemId: "some") { _ in }

        XCTAssertTrue(faqRequestLoopMock.executeCalled)
    }

    func testDislikeValidURL() {
        sut.dislike(itemId: "some") { _ in }
        let expectedURL =  baseURL + FAQActions.ServerPathSuffix.dislike.rawValue

        XCTAssertEqual(faqRequestLoopMock.webimRequest?.getBaseURLString(), expectedURL)
    }

    func testTrackMethodCall() {
        sut.track(itemId: "some", openFrom: FAQItemSource.search)

        XCTAssertTrue(faqRequestLoopMock.executeCalled)
    }

    func testTrackValidURL() {
        sut.track(itemId: "some", openFrom: FAQItemSource.tree)
        let expectedURL =  baseURL + FAQActions.ServerPathSuffix.track.rawValue

        XCTAssertEqual(faqRequestLoopMock.webimRequest?.getBaseURLString(), expectedURL)
    }
    
}
