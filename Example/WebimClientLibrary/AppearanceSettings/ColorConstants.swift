//
//  File.swift
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

import UIKit

// MARK: - Colors

fileprivate let RED_COLOR = UIColor(red: (192.0 / 255.0),
                                    green: (0.0 / 255.0),
                                    blue: (64.0 / 255.0),
                                    alpha: 1.0)

// MARK: Classic scheme
fileprivate let BACKGROUND_CELL_LIGHT_COLOR_CLASSIC = UIColor.white
//Background main color light(StartVC)
fileprivate let BACKGROUND_MAIN_COLOR_CLASSIC = UIColor.white
fileprivate let BACKGROUND_SECONDARY_COLOR_CLASSIC = BACKGROUND_MAIN_COLOR_CLASSIC
fileprivate let BACKGROUND_TABLE_VIEW_COLOR_CLASSIC = UIColor.white
//cell field(SettingsVC)
fileprivate let BACKGROUND_TEXT_FIELD_COLOR_CLASSIC = UIColor(red: (239.0 / 255.0),
                                                              green: (239.0 / 255.0),
                                                              blue: (244.0 / 255.0),
                                                              alpha: 1.0)
fileprivate let BUTTON_BORDER_COLOR_CLASSIC = UIColor(red: (67.0 / 255.0),
                                                      green: (67.0 / 255.0),
                                                      blue: (67.0 / 255.0),
                                                      alpha: 1.0)
//startChatButton light(StartVC)
fileprivate let BUTTON_COLOR_CLASSIC = UIColor(red: (11 / 255.0),
                                               green: (180.0 / 255.0),
                                               blue: (168.0 / 255.0),
                                               alpha: 1.0)
//separation_light between light and dark(SettingsVC)
fileprivate let DELIMITER_COLOR_CLASSIC = BACKGROUND_MAIN_COLOR_CLASSIC
//startChatButton_light text(StartVC)
fileprivate let TEXT_BUTTON_COLOR_CLASSIC = BACKGROUND_MAIN_COLOR_CLASSIC
//settingsButton_light text and border(StartVC)
fileprivate let TEXT_BUTTON_TRANSPARENT_COLOR_CLASSIC = BACKGROUND_MAIN_COLOR_DARK
fileprivate let TEXT_BUTTON_TRANSPARENT_HIGHLIGHTED_COLOR_CLASSIC = UIColor.lightGray
//text in separation light(SettingsVC)
fileprivate let TEXT_CELL_LIGHT_COLOR_CLASSIC = BACKGROUND_MAIN_COLOR_DARK
//start_text_main_light color(StartVC)
fileprivate let TEXT_MAIN_COLOR_CLASSIC = BACKGROUND_MAIN_COLOR_DARK
fileprivate let TEXT_NAME_OPERATOR_COLOR_CLASSIC = RED_COLOR
fileprivate let TEXT_NAME_VISITOR_COLOR_CLASSIC = UIColor(red: (0.0 / 255.0),
                                                          green: (152.0 / 255.0),
                                                          blue: (79.0 / 255.0),
                                                          alpha: 1.0)
fileprivate let TEXT_SECONDARY_COLOR_CLASSIC = UIColor.darkGray
//cell text light(SettingsVC)
fileprivate let TEXT_TEXT_FIELD_COLOR_CLASSIC = BACKGROUND_MAIN_COLOR_DARK
fileprivate let TEXT_TEXT_FIELD_ERROR_COLOR_CLASSIC = RED_COLOR
//start_text_tint_main_light color(StartVC)
fileprivate let TEXT_TINT_COLOR_CLASSIC = BUTTON_COLOR_CLASSIC

// MARK: Dark theme
//(SettingsVC)
fileprivate let BACKGROUND_CELL_LIGHT_COLOR_DARK = BACKGROUND_MAIN_COLOR_DARK
//Background main color dark(StartVC)
fileprivate let BACKGROUND_MAIN_COLOR_DARK = UIColor(red: (47.0 / 255.0),
                                                     green: (49.0 / 255.0),
                                                     blue: (95.0 / 255.0),
                                                     alpha: 1.0)
//top of the screen dark(StartVC)
fileprivate let BACKGROUND_SECONDARY_COLOR_DARK = BACKGROUND_MAIN_COLOR_DARK
//(ChatVC)
fileprivate let BACKGROUND_TABLE_VIEW_COLOR_DARK = BACKGROUND_MAIN_COLOR_DARK
//cell field(SettingsVC)
fileprivate let BACKGROUND_TEXT_FIELD_COLOR_DARK = BACKGROUND_TEXT_FIELD_COLOR_CLASSIC
fileprivate let BUTTON_BORDER_COLOR_DARK = BUTTON_BORDER_COLOR_CLASSIC
//startChatButton light(StartVC)
fileprivate let BUTTON_COLOR_DARK = BUTTON_COLOR_CLASSIC
//separation_dark between light and dark(SettingsVC)
fileprivate let DELIMITER_COLOR_DARK = BACKGROUND_MAIN_COLOR_DARK
//startChatButton_light text(StartVC)
fileprivate let TEXT_BUTTON_COLOR_DARK = UIColor.white
//settingsButton_dark text and border(StartVC)
fileprivate let TEXT_BUTTON_TRANSPARENT_COLOR_DARK = UIColor.white
fileprivate let TEXT_BUTTON_TRANSPARENT_HIGHLIGHTED_COLOR_DARK = UIColor.white
//text in separation light(SettingsVC)
fileprivate let TEXT_CELL_LIGHT_COLOR_DARK = UIColor.white
fileprivate let TEXT_MAIN_COLOR_DARK = UIColor.white
fileprivate let TEXT_NAME_OPERATOR_COLOR_DARK = TEXT_NAME_OPERATOR_COLOR_CLASSIC
fileprivate let TEXT_NAME_VISITOR_COLOR_DARK = TEXT_NAME_VISITOR_COLOR_CLASSIC
fileprivate let TEXT_SECONDARY_COLOR_DARK = UIColor.lightGray
//cell text dark(SettingsVC)
fileprivate let TEXT_TEXT_FIELD_COLOR_DARK = BACKGROUND_MAIN_COLOR_DARK
fileprivate let TEXT_TEXT_FIELD_ERROR_COLOR_DARK = TEXT_TEXT_FIELD_ERROR_COLOR_CLASSIC
//start_text_tint_main_dark color(StartVC)
fileprivate let TEXT_TINT_COLOR_DARK = BUTTON_COLOR_CLASSIC

// MARK: - Model
let backgroundCellLightColor = SchemeColor(classic: BACKGROUND_CELL_LIGHT_COLOR_CLASSIC,
                                           dark: BACKGROUND_CELL_LIGHT_COLOR_DARK)
let backgroundMainColor = SchemeColor(classic: BACKGROUND_MAIN_COLOR_CLASSIC,
                                      dark: BACKGROUND_MAIN_COLOR_DARK)
let backgroundSecondaryColor = SchemeColor(classic: BACKGROUND_SECONDARY_COLOR_CLASSIC,
                                           dark: BACKGROUND_SECONDARY_COLOR_DARK)
let backgroundTableViewColor = SchemeColor(classic: BACKGROUND_TABLE_VIEW_COLOR_CLASSIC,
                                           dark: BACKGROUND_TABLE_VIEW_COLOR_DARK)
let backgroundTextFieldColor = SchemeColor(classic: BACKGROUND_TEXT_FIELD_COLOR_CLASSIC,
                                           dark: BACKGROUND_TEXT_FIELD_COLOR_DARK)
let buttonBorderColor = SchemeColor(classic: BUTTON_BORDER_COLOR_CLASSIC,
                                    dark: BUTTON_BORDER_COLOR_DARK)
let buttonColor = SchemeColor(classic: BUTTON_COLOR_CLASSIC,
                              dark: BUTTON_COLOR_DARK)
let delimiterColor = SchemeColor(classic: DELIMITER_COLOR_CLASSIC,
                                 dark: DELIMITER_COLOR_DARK)
let textButtonColor = SchemeColor(classic: TEXT_BUTTON_COLOR_CLASSIC,
                                  dark: TEXT_BUTTON_COLOR_DARK)
let textButtonTransparentColor = SchemeColor(classic: TEXT_BUTTON_TRANSPARENT_COLOR_CLASSIC,
                                             dark: TEXT_BUTTON_TRANSPARENT_COLOR_DARK)
let textButtonTransparentHighlightedColor = SchemeColor(classic: TEXT_BUTTON_TRANSPARENT_HIGHLIGHTED_COLOR_CLASSIC,
                                                        dark: TEXT_BUTTON_TRANSPARENT_HIGHLIGHTED_COLOR_DARK)
let textCellLightColor = SchemeColor(classic: TEXT_CELL_LIGHT_COLOR_CLASSIC,
                                     dark: TEXT_CELL_LIGHT_COLOR_DARK)
let textMainColor = SchemeColor(classic: TEXT_MAIN_COLOR_CLASSIC,
                                dark: TEXT_MAIN_COLOR_DARK)
let textNameOperatorColor = SchemeColor(classic: TEXT_NAME_OPERATOR_COLOR_CLASSIC,
                                        dark: TEXT_NAME_OPERATOR_COLOR_DARK)
let textNameVisitorColor = SchemeColor(classic: TEXT_NAME_VISITOR_COLOR_CLASSIC,
                                       dark: TEXT_NAME_VISITOR_COLOR_DARK)
let textSecondaryColor = SchemeColor(classic: TEXT_SECONDARY_COLOR_CLASSIC,
                                     dark: TEXT_SECONDARY_COLOR_DARK)
let textTextFieldColor = SchemeColor(classic: TEXT_TEXT_FIELD_COLOR_CLASSIC,
                                     dark: TEXT_TEXT_FIELD_COLOR_DARK)
let textTextFieldErrorColor = SchemeColor(classic: TEXT_TEXT_FIELD_ERROR_COLOR_CLASSIC,
                                          dark: TEXT_TEXT_FIELD_ERROR_COLOR_CLASSIC)
let textTintColor = SchemeColor(classic: TEXT_TINT_COLOR_CLASSIC,
                                dark: TEXT_TINT_COLOR_DARK)
