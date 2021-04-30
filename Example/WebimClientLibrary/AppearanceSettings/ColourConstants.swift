//
//  ColourConstants.swift
//  WebimClientLibrary_Example
//
//  Created by Eugene Ilyin on 15.10.2019.
//  Copyright © 2019 Webim. All rights reserved.
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
import UIKit

// MARK: - Colours
fileprivate let CLEAR = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
fileprivate let WHITE = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
fileprivate let BLACK = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
fileprivate let LIGHT_GREY = #colorLiteral(red: 0.8823529412, green: 0.8901960784, blue: 0.9176470588, alpha: 1)
fileprivate let GREY = #colorLiteral(red: 0.4901960784, green: 0.4980392157, blue: 0.5843137255, alpha: 1)
fileprivate let NO_CONNECTION_GREY = #colorLiteral(red: 0.4784313725, green: 0.4941176471, blue: 0.5803921569, alpha: 1)
fileprivate let TRANSLUCENT_GREY = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5)
fileprivate let WEBIM_CYAN = #colorLiteral(red: 0.08675732464, green: 0.6737991571, blue: 0.8237424493, alpha: 1)
fileprivate let WEBIM_PUPRLE = #colorLiteral(red: 0.1529411765, green: 0.1647058824, blue: 0.3058823529, alpha: 1)
fileprivate let WEBIM_LIGHT_PURPLE = #colorLiteral(red: 0.4117647059, green: 0.4235294118, blue: 0.568627451, alpha: 1)
fileprivate let WEBIM_RED = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
fileprivate let WEBIM_GREY = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)

// MARK: - Views' colour properties
// FlexibleTableViewCell.swift
let flexibleTableViewCellBackgroundColour = CLEAR
/// System
let messageBodyLabelColourSystem = WEBIM_LIGHT_PURPLE
let messageBackgroundViewColourSystem = LIGHT_GREY
let messageBackgroundViewColourClear = CLEAR
/// Visitor
let messageBodyLabelColourVisitor = WHITE
let messageBackgroundViewColourVisitor = WEBIM_CYAN
let documentFileNameLabelColourVisitor = WHITE
let documentFileDescriptionLabelColourVisitor = LIGHT_GREY
let quoteLineViewColourVisitor = WHITE
let quoteUsernameLabelColourVisitor = WHITE
let quoteBodyLabelColourVisitor = LIGHT_GREY
/// Operator
let messageUsernameLabelColourOperator = WEBIM_CYAN
let messageBodyLabelColourOperator = WEBIM_PUPRLE
let messageBackgroundViewColourOperator = WHITE
let documentFileNameLabelColourOperator = WEBIM_PUPRLE
let documentFileDescriptionLabelColourOperator = GREY
let imageUsernameLabelColourOperator = WHITE
let imageUsernameLabelBackgroundViewColourOperator = WEBIM_GREY
let quoteLineViewColourOperator = WEBIM_CYAN
let quoteUsernameLabelColourOperator = WEBIM_PUPRLE
/// Other
let quoteBodyLabelColourOperator = GREY
let dateLabelColour = GREY
let timeLabelColour = GREY
let messageStatusIndicatorColour = WEBIM_PUPRLE.cgColor
let documentFileStatusPercentageIndicatorColour = WEBIM_CYAN.cgColor
let buttonDefaultBackgroundColour = WHITE
let buttonChoosenBackgroundColour = WEBIM_CYAN
let buttonCanceledBackgroundColour = WHITE
let buttonDefaultTitleColour = WEBIM_CYAN
let buttonChoosenTitleColour = WHITE
let buttonCanceledTitleColour = WEBIM_GREY

// RatingDialogViewController.swift
let ratingDialogOperatorNameLabelColour = WEBIM_PUPRLE
let ratingDialogTitleLabelColour = WEBIM_LIGHT_PURPLE
let ratingDialogBackgroundColour = TRANSLUCENT_GREY
let ratingDialogWhiteBackgroudColour = WHITE

let cosmosViewFilledColour = WEBIM_CYAN
let cosmosViewFilledBorderColour = WEBIM_CYAN
let cosmosViewEmptyColour = CLEAR
let cosmosViewEmptyBorderColour = GREY

// PopupActionTableViewCell.swift
let actionColourCommon = WHITE
let actionColourDelete = WEBIM_RED

// ChatViewController.swift
/// Separator
let bottomBarSeparatorColour = TRANSLUCENT_GREY
/// Bottom bar
let bottomBarBackgroundViewColour = WHITE
let bottomBarQuoteLineViewColour = WEBIM_CYAN
let textInputBackgroundViewBorderColour = LIGHT_GREY.cgColor
/// Bottom bar for edit/reply
let textInputViewPlaceholderLabelTextColour = GREY
let textInputViewPlaceholderLabelBackgroundColour = CLEAR

// ChatTableViewController.swift
let refreshControlTextColour = WEBIM_PUPRLE
let refreshControlTintColour = WEBIM_PUPRLE

// ImageViewController.swift
// FileViewController.swift
let topBarTintColourDefault = WEBIM_PUPRLE
let topBarTintColourClear = CLEAR

// PopupActionViewController.swift
let popupBackgroundColour = CLEAR
let actionsTableViewBackgroundColour = BLACK
let separatorViewBackgroundColour = WHITE
let actionsTableViewCellBackgroundColour = CLEAR

// SettingsViewController.swift
let backgroundViewColour = WHITE
let saveButtonBackgroundColour = WEBIM_CYAN
let saveButtonTitleColour = WHITE
let saveButtonBorderColour = BLACK.cgColor

// SettingsTableViewController.swift
let tableViewBackgroundColour = WHITE
let labelTextColour = WEBIM_PUPRLE
let textFieldTextColour = WEBIM_PUPRLE
let textFieldTintColour = WEBIM_PUPRLE
let editViewBackgroundColourEditing = WEBIM_CYAN
let editViewBackgroundColourError = WEBIM_RED
let editViewBackgroundColourDefault = GREY

// StartViewController.swift
let startViewBackgroundColour = WEBIM_PUPRLE
let navigationBarBarTintColour = WEBIM_PUPRLE
let navigationBarNoConnectionColour = NO_CONNECTION_GREY
let navigationBarTintColour = WHITE
let welcomeLabelTextColour = WHITE
let welcomeTextViewTextColour = WHITE
let welcomeTextViewForegroundColour = WEBIM_CYAN
let startChatButtonBackgroundColour = WEBIM_CYAN
let startChatButtonBorderColour = WEBIM_CYAN.cgColor
let startChatTitleColour = WHITE
let settingsButtonTitleColour = WHITE
let settingButtonBorderColour = GREY.cgColor

// UITableView extension
let textMainColour = WEBIM_PUPRLE
