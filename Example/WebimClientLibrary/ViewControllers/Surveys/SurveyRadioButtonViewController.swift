//
//  SurveyRadioButtonViewController.swift
//  WebimClientLibrary_Example
//
//  Created by Возлеев Юрий on 12.03.2021.
//  Copyright © 2021 Webim. All rights reserved.
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

import AVFoundation
import UIKit

class SurveyRadioButtonViewController: WMSurveyViewController, WMFixedWidthViewDelegate {

    var descriptionText: String?
    var points: [String] = []
    var selectedPoint = -1
    
    var savedHeaderHeight: CGFloat = 0
    @IBOutlet var tableHeaderView: WMFixedWidthView!
    
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var grayViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButtonView: UIView!
    
    private var cells = [SurveyTableViewCell]()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionLabel.text = descriptionText
        descriptionLabel.setNeedsLayout()
        
        self.tableHeaderView.delegate = self
        
        for text in points {
            let cell = tableView.dequeueReusableCellWithType(SurveyTableViewCell.self)
            cell.pointTitle.text = text
            self.cells.append(cell)
        }
        
        self.disableSendButton()
        self.tableView.reloadData()
        self.view.setNeedsLayout()
        recountContentViewHeight()
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc
    func rotated() {
        recountContentViewHeight()
    }
    
    @IBAction private func send(_ sender: Any) {
        // important: radio button answer numeration starts from 1
        self.delegate?.sendSurveyAnswer("\(selectedPoint + 1)")
        self.closeViewController()
    }
    
    func viewWillResize(_ view: UIView) {
        DispatchQueue.main.asyncAfter(deadline: .now() ) {
            self.tableView.reloadData()
            self.recountContentViewHeight()
        }
    }
    
    func recountContentViewHeight() {
        let contentViewHeight = self.tableView.contentSize.height + self.sendButtonView.frame.height + self.tableHeaderView.frame.height
        
        var greyViewHeight = max(WMInterfaceData.shared.screenHeight() - contentViewHeight, 0)
        if greyViewHeight < 100 {
            if WMInterfaceData.shared.screenHeight() < 450 {
                greyViewHeight = 0
            } else {
                greyViewHeight = 100
            }
        }
        self.grayViewHeightConstraint.constant = greyViewHeight
    }
}

extension SurveyRadioButtonViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.savedHeaderHeight != self.tableHeaderView.frame.height {
            self.savedHeaderHeight = self.tableHeaderView.frame.height
            self.tableView.reloadData()
        }

        return self.tableHeaderView.frame.height
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.tableHeaderView
    }

    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return points.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.cells[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPoint = indexPath.row
        self.enableSendButton()
        for index in 0 ..< points.count {
            cells[index].setSelected(index == self.selectedPoint)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
