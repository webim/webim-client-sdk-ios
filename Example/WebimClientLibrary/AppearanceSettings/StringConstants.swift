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

enum NoCurrentOperatorErrorMessage: String {
    case title = "NoCurrentOperator"
    case buttonTitle = "OK"
    case message = "NoAvailableOperator"
}

enum AlertDialog: String {
    case rateSuccessTitle = "RateSuccessTitle"
    case rateSuccessMessage = "RateSuccessMessage"
    
    case buttonTitle = "OK"
    case buttonAccessibilityHint = "ClosesRateOperatorError"
}

enum RateOperatorErrorMessage: String {
    case title = "OperatorRatingFailed"

    // ErrorMessage text
    case rateOperatorNoChat = "RateOperatorNoChat"
    case rateOperatorWrongID = "RateOperatorWrongID"
    case rateOperatorLongNote = "RateOperatorLongNote"
}

enum SendErrorMessage: String {
    case buttonTitle = "OK"
    case buttonAccessibilityHint = "ClosesFileError"
}

enum SendFileErrorMessage: String {
    case title = "FileSendingFailed"
    
    // Error messages
    case fileSizeExceeded = "FileTooLarge"
    case fileTypeNotAllowed = "FileTypeNotSupported"
    case fileNotFound = "FileNotFound"
    case unknownError = "FileSendingUnknownError"
    case unauthorized = "FileSengingUnauthorized"
}

enum SendMessageErrorMessage: String {
    case messageEmpty = "MessageIsEmpty"
    case maxMessageLengthExceede = "MaxMessageLengthExceeded"
}

enum EditMessageErrorMessage: String {
    case title = "EditMessageFailed"
    
    // Error messages
    case unknownError = "EditMessageUnknownError"
    case notAllowed = "EditingMessagesIsTurnedOffOnTheServer"
    case messageEmpty = "EditingMessageIsEmpty"
    case messageNotOwned = "MessageNotOwnedByVisitor"
    case maxMessageLengthExceede = "MaxMessageLengthExceeded"
    case wrongMessageKind = "WrongMessageKind"
}

enum DeleteMessageErrorMessage: String {
    case title = "DeleteMessageFailed"
    
    // Error messages
    case unknownError = "DeleteMessageUnknownError"
    case notAllowed = "DeletingMessagesIsTurnedOffOnTheServer"
    case messageNotOwned = "MessageNotOwnedByVisitor"
    case messageNotFound = "MessageNotFound"
}

enum SendKeyboardRequestErrorMessage: String {
    case title = "SendKeyboardRequestFailed"
    
    // Error messages
    case unknownError = "SendKeyboardRequestUnknownError"
    case noChat = "ChatDoesNotExist"
    case buttonIDNotSet = "WrongButtonID"
    case requestMessageIDNotSet = "WrongMessageID"
    case cannotCreateResponse = "ResponseCannotBeCreated"
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
    case welcomeTitle = "WelcomeTitle"
    case welcomeText = "WelcomeText"
    
    case startButtonTitle = "StartChat"
    case settingsButtonTitle = "Settings"
}

enum TableView: String {
    case emptyTableViewText = "EmptyChat"
}

enum ChatTableView: String {
    case refreshControlText = "LoadMessages"
}

enum FileView: String {
    case loadingFileText = "LoadingFile"
}

enum ChatView: String {
    case hardcodedVisitorMessageName = "HardcodedVisitorMessageName"
    case editMessageText = "EditMessage"
    case textInputPlaceholderText = "InputPlaceholderText"
    case navigationBarAccessibilityLabelText = "AccessibilityTextWebimLogo"
}

enum PopupAction: String {
    case reply = "Reply"
    case copy = "Copy"
    case edit = "Edit"
    case delete = "Delete"
}

enum RatingDialogView: String {
    case rateTitleText = "RateOperator"
}

enum SavingImageDialog: String {
    case buttonTitle = "OK"
    case saveErrorTitle = "SaveError"
    
    case saveSuccessTitle = "Saved"
    case saveSuccessMessage = "ImageSaved"
}

enum SavingFileDialog: String {
    case buttonTitle = "OK"
    case saveErrorTitle = "SaveError"
    
    case saveSuccessTitle = "Saved"
    case saveSuccessMessage = "FileSaved"
}

enum LoadingFileDialog: String {
    case buttonTitle = "OK"
    case loadErrorTitle = "LoadError"
}

enum OperatorStatus: String {
    case noOperator = "NoOperator"
    case allOperatorsOffline = "OperatorsOffline"
    case online = "Online"
    case isTyping = "IsTyping"
}

enum OperatorAvatar: String {
    case placeholder = "NoAvatarURL"
    case empty = "GhostImage"
}

enum FilePickerObject: String {
    case actionCamera = "Camera"
    case actionPhotoLibrary = "PhotoLibrary"
    case actionFile = "File"
    case actionCancel = "Cancel"
    
    case cameraNotAvailable = "CameraIsNotAvailable"
    case ok = "OK"
    
    case cameraAccessTitle = "CameraAccessTitle"
    case cameraAccessMessage = "CameraAccessMessage"
    case cameraAccessOpenSetting = "CameraAccessOpenSettings"
    case cameraAccessCancel = "CameraAccessCancel"
}

enum MessageStatus: String {
    case editedMessage = "EditedMessage"
}

enum FlexibleCellDate: String {
    case dateToday = "DateToday"
    case dateYesterday = "DateYesterday"
}

enum UploadingFileDescription: String {
    case uploadingFile = "UploadingFile"
    case counting = "Counting"
}
