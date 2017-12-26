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

let REFRESH_CONTROL_TEXT = NSAttributedString(string: NSLocalizedString("LoadingMessages",
                                                                        comment: ""))

enum Avatar: String {
    case ACCESSIBILITY_LABEL = "SenderAvatarImage"
    case ACCESSIBILITY_HINT_FOR_OPERATOR = "ShowsRatingDialog"
}

enum FileMessage: String {
    case FILE_UNAVAILABLE = "FileUnavailable"
}

enum LeftButton: String {
    case ACCESSIBILITY_LABEL = "ChooseFile"
    case ACCESSIBILITY_HINT = "ShowsImagePicker"
}

enum RateOperatorErrorMessage: String {
    case TITLE = "OperatorRatingFailed"
    
    case BUTTON_TITLE = "OK"
    case BUTTON_ACCESSIBILITY_HINT = "ClosesRateOperatorError"

    case MESSAGE = "RateOperatorErrorMessage"
}

enum RatingDialog: String {
    case ACTION_BUTTON_TITLE = "Rate"
    case CANCEL_BUTTON_TITLE = "Cancel"
    
    case ACTION_BUTTON_ACCESSIBILITY_HINT = "RatesOperator"
    case CANCEL_BUTTON_ACCESSIBILITY_HINT = "ClosesRatingDialog"
}

enum SendFileErrorMessage: String {
    case TITLE = "FileSendingFailed"
    
    case BUTTON_TITLE = "OK"
    case BUTTON_ACCESSIBILITY_HINT = "ClosesSendFileError"
    
    // Error messages.
    case FILE_SIZE_EXCEEDED = "FileTooLarge"
    case FILE_TYPE_NOT_ALLOWED = "FileTypeNotSupported"
}

enum SessionCreationErrorDialog: String {
    case BUTTON_TITLE = "OK"
    case BUTTON_ACCESSIBILITY_HINT = "ClosesSessionError"
    
    case TITLE = "SessionCreationFailed"
    
    case ACCOUNT_BLOCKED = "AccountBlocked"
    case VISITOR_BANNED = "VisitorBanned"
}

enum SettingsErrorDialog: String {
    case BUTTON_TITLE = "OK"
    case BUTTON_ACCESSIBILITY_HINT = "ClosesSettingsError"
    
    case TITLE = "InvalidSettings"
    case WRONG_ACCOUNT_NAME_MESSAGE = "AccountNameEmpty"
    case WRONG_LOCATION_MESSAGE = "LocationEmpty"
}

enum ShowFileDialog: String {
    case BUTTON_TITLE = "OK"
    
    // Message.
    case INVALID_IMAGE_FORMAT = "ImageFormatInvalid."
    case INVALID_IMAGE_LINK = "ImageLinkInvalid."
    case NOT_IMAGE = "PreviewUnavailable."
    
    case ACCESSIBILITY_HINT = "ClosesFilePreview"
}
