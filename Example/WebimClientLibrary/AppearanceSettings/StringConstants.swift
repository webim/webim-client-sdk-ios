//
//  StringConstants.swift
//  WebimClientLibrary_Example
//
//  Created by Nikita Lazarev-Zubov on 19.10.17.
//  Copyright © 2017 Webim. All rights reserved.
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

enum Avatar: String {
    case accessibilityLabel = "SenderAvatarImage"
    case accessibilityHintOperator = "ShowsRatingDialog"
}

enum BackButton: String {
    case accessibilityLabel = "Back"
    case accessibilityHint = "ClosesScreen"
}

enum ChatClosedDialog: String {
    case message = "ChatClosed"
    
    case buttonTitle = "OK"
    case buttonAccessibilityHint = "ClosesDialog"
}

enum CloseChatButton: String {
    case accessibilityLabel = "CloseChat"
    case accessibilityHint = "ClosesChat"
}

enum DepartmentListDialog: String {
    case title = "ContactTopic"
    
    case buttonAccessibilityHint = "ChoosesTopic"
    
    case cancelButtonTitle = "Cancel"
    case cancelButtonAccessibilityHint = "ClosesDialog"
}

enum FileMessage: String {
    case fileUnavailable = "FileUnavailable"
}

enum LeftButton: String {
    case accessibilityLabel = "ChooseFile"
    case accessibilityHint = "ShowsImagePicker"
}

enum RateOperatorErrorMessage: String {
    case title = "OperatorRatingFailed"
    
    case buttonTitle = "OK"
    case buttonAccessibilityHint = "ClosesRateOperatorError"

    case message = "RateOperatorErrorMessage"
}

enum RatingDialog: String {
    case actionButtonAccessibilityHint = "RatesOperator"
    case actionButtonTitle = "Rate"
    
    case cancelButtonAccessibilityHint = "ClosesRatingDialog"
    case cancelButtonTitle = "Cancel"
}

enum SendFileErrorMessage: String {
    case title = "FileSendingFailed"
    
    case buttonTitle = "OK"
    case buttonAccessibilityHint = "ClosesSendFileError"
    
    // Error messages
    case fileSizeExceeded = "FileTooLarge"
    case fileTypeNotAllowed = "FileTypeNotSupported"
    case fileNotFound = "FileNotFound"
    case unknownError = "FileSendingUnknownError"
    case unauthorized = "FileSengingUnauthorized"
}

enum SessionCreationErrorDialog: String {
    case buttonTitle = "OK"
    case buttonAccessibilityHint = "ClosesSessionError"
    
    case title = "SessionCreationFailed"
    
    // Error messages
    case accountBlocked = "AccountBlocked"
    case visitorBanned = "VisitorBanned"
}

enum SettingsErrorDialog: String {
    case buttonTitle = "OK"
    case buttonAccessibilityHint = "ClosesSettingsError"
    
    case title = "InvalidSettings"
    
    // Error messages
    case wrongAccountName = "AccountNameEmpty"
    case wrongLocation = "LocationEmpty"
}

enum ShowFileDialog: String {
    case buttonTitle = "OK"
    
    // Error messages
    case imageFormatInvalid = "ImageFormatInvalid"
    case imageLinkInvalid = "ImageLinkInvalid"
    case notImage = "PreviewUnavailable"
    
    case accessibilityHint = "ClosesFilePreview"
}

enum StartView: String {
    case welcomeText = "Welcome to the WebimClientLibrary demo app!\n\nTo start a chat tap on the button below.\n\nOperator can answer to your chat at:\nhttps://demo.webim.ru/\nLogin: o@webim.ru\nPassword: password\n\nThis app source code can be found at:\nhttps://github.com/webim/webim-client-sdk-ios"
}

enum TableView: String {
    case refreshControlText = "LoadingMessages"
    case emptyTableViewText = "EmptyChat"
}
