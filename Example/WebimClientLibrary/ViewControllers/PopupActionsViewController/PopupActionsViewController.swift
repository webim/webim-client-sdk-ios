//
//  NewPopupActionsViewController.swift
//  WebimClientLibrary_Example
//
//  Created by Eugene Ilyin on 28.10.2019.
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

import AVFoundation
import UIKit

protocol WMDialogPopoverDelegate: AnyObject {
    func deleteMessage()
    func addQuoteEditBar()
    func addQuoteReplyBar()
    func copyMessage()
    func hideQuoteView()
    func likeMessage()
    func dislikeMessage()
    func hideOverlayWindow()
    func removeQuoteEditBar()
}

class PopupActionsViewController: UIViewController {
    // MARK: - ActionsTableView positions
    private enum ActionsTableViewPosition {
        case top, bottom
    }
    
    // MARK: - Size constants
    // HINT: Look for same properties in FlexibleTableViewCell.swift
    fileprivate let CELL_SPACING_DEFAULT: CGFloat = 10.0
    fileprivate let USERAVATARIMAGEVIEW_WIDTH: CGFloat = 40.0
    
    // MARK: - Properties
    enum OriginalCellAlignment {
        case leading, center, trailing
    }
    var cellImageViewImage = UIImage()
    var cellImageViewHeight = CGFloat()
    var cellImageViewCenterYPosition = CGFloat()
    var actions = [PopupAction]()
    var originalCellAlignment = OriginalCellAlignment.center
    
    weak var delegate: WMDialogPopoverDelegate?
    
    // MARK: - Private properties
    private var actionsTableViewCenterYPosition = CGFloat()
    private var actionsTableViewContentHeight = CGFloat()
    
    // MARK: - Subviews
    lazy var blurBackground: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurEffectView
    }()
    lazy var cellImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    lazy var actionsTableView: UITableView = {
        return UITableView()
    }()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        AudioServicesPlaySystemSound(1519) // Actuate "Peek" feedback (weak boom)
        view.backgroundColor = popupBackgroundColour
        
        setupSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.delegate?.removeQuoteEditBar()
        findAvailableSpace()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let index = self.actionsTableView.indexPathForSelectedRow {
            self.actionsTableView.deselectRow(at: index, animated: true)
        }
        AppDelegate.keyboardHidden(false)
    }
    
    // MARK: - Methods
    func findAvailableSpace() {
        let yValueImageViewTopEdge = cellImageViewCenterYPosition - cellImageViewHeight / 2
        let yValueImageViewBottomEdge = cellImageViewCenterYPosition + cellImageViewHeight / 2
        var yValueTopScreen = CGFloat()
        var yValueBottomScreen = CGFloat()
        if #available(iOS 11.0, *) {
            yValueTopScreen = self.view.safeAreaLayoutGuide.layoutFrame.minY
            yValueBottomScreen = self.view.safeAreaLayoutGuide.layoutFrame.maxY
        } else {
            yValueTopScreen = self.view.frame.minY
            yValueBottomScreen = self.view.frame.maxY
        }
        
        let topSpace = yValueImageViewTopEdge - yValueTopScreen
        let bottomSpace = yValueBottomScreen - yValueImageViewBottomEdge
        
        if bottomSpace > 0 && bottomSpace > actionsTableViewContentHeight {
            // There is space on the bottom
            positionActionsTableView(on: .bottom)
        } else if topSpace > 0 && topSpace > actionsTableViewContentHeight {
            // There is space on the top
            positionActionsTableView(on: .top)
        } else {
            // Content out of bounds
            var neededBottomSpaceToAdd = CGFloat()
            neededBottomSpaceToAdd = actionsTableViewContentHeight - bottomSpace
            cellImageViewCenterYPosition -= neededBottomSpaceToAdd
            positionCellImageView(withAnimationDuration: 0.5)
            positionActionsTableView(on: .bottom)
        }
    }
    
    // MARK: - Private methods
    private func setupSubviews() {
        setupBackground()
        
        setupCellImageView()
        setupActionsTableView()
    }
    
    private func setupBackground() {
        view.addSubview(blurBackground)
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(hidePopupActionsViewController)
        )
        tapGestureRecognizer.cancelsTouchesInView = false
        tapGestureRecognizer.delegate = self
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setupActionsTableView() {
        actionsTableView.delegate = self
        actionsTableView.dataSource = self
        
        actionsTableView.backgroundColor = actionsTableViewBackgroundColour
        actionsTableView.layer.cornerRadius = 20
        actionsTableView.clipsToBounds = true
        actionsTableView.isScrollEnabled = false
        
        actionsTableView.rowHeight = 40.0
        actionsTableView.separatorStyle = .none
        
        actionsTableView.register(
            PopupActionsTableViewCell.self,
            forCellReuseIdentifier: "PopupActionsTableViewCell"
        )
        
        actionsTableViewContentHeight = actionsTableView.rowHeight * CGFloat(actions.count)
        
        view.addSubview(actionsTableView)
    }
    
    @objc func hidePopupActionsViewController() {
        dismiss(animated: false)
        self.delegate?.hideOverlayWindow()
    }
    
    private func setupCellImageView() {
        cellImageView.image = cellImageViewImage
        cellImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cellImageView)
        cellImageView.snp.remakeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalTo(cellImageViewCenterYPosition)
        }
    }
    
    private func positionCellImageView() {
        cellImageView.snp.remakeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalTo(cellImageViewCenterYPosition)
        }
        self.view.layoutIfNeeded()
    }
    
    private func positionCellImageView(withAnimationDuration: TimeInterval) {
        UIView.animate(withDuration: withAnimationDuration) {
            self.cellImageView.snp.remakeConstraints { (make) in
                make.leading.trailing.equalToSuperview()
                make.centerY.equalTo(self.cellImageViewCenterYPosition)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    private func positionActionsTableView(on position: ActionsTableViewPosition) {
        var actionsTableViewCenterYPosition: CGFloat = 0
        switch position {
        case .top:
            actionsTableViewCenterYPosition =
            cellImageViewCenterYPosition -
            cellImageViewHeight / 2 -
            actionsTableViewContentHeight / 2
            
        case .bottom:
            actionsTableViewCenterYPosition =
            cellImageViewCenterYPosition +
            cellImageViewHeight / 2 +
            actionsTableViewContentHeight / 2
        }
        
        actionsTableView.snp.remakeConstraints { (make) -> Void in
            make.centerY.equalTo(actionsTableViewCenterYPosition)
            
            switch originalCellAlignment {
            case .center:
                make.centerX.equalToSuperview()
                
            case .leading:
                if #available(iOS 11.0, *) {
                    make.leading.equalTo(self.view.safeAreaLayoutGuide)
                        .inset(2 * CELL_SPACING_DEFAULT + USERAVATARIMAGEVIEW_WIDTH)
                } else {
                    make.leading.equalToSuperview()
                        .inset(2 * CELL_SPACING_DEFAULT + USERAVATARIMAGEVIEW_WIDTH)
                }
                
            case .trailing:
                if #available(iOS 11.0, *) {
                    make.trailing.equalTo(self.view.safeAreaLayoutGuide)
                        .inset(10)
                } else {
                    make.trailing.equalToSuperview()
                        .inset(10)
                }
            }
            
            make.height.equalTo(actionsTableViewContentHeight)
            make.width.equalTo(200.0)
        }
    }
}

// MARK: - TableViewMethods
extension PopupActionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int { actions.count }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch actions[indexPath.row] {
            
        case .reply:
            self.delegate?.addQuoteReplyBar()
        case .copy:
            self.delegate?.copyMessage()
        case .edit:
            self.delegate?.addQuoteEditBar()
        case .delete:
            self.delegate?.deleteMessage()
        case .like:
            self.delegate?.likeMessage()
        case .dislike:
            self.delegate?.dislikeMessage()
        }
        
        hidePopupActionsViewController()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "PopupActionsTableViewCell",
            for: indexPath) as? PopupActionsTableViewCell
        else {
            fatalError("The dequeued cell is not an instance of PopupActionsTableViewCell.")
        }
        
        cell.backgroundColor = actionsTableViewCellBackgroundColour
        cell.setupCell(forAction: actions[indexPath.row])
        return cell
    }
}

extension PopupActionsViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool { !(touch.view?.isDescendant(of: self.actionsTableView) ?? false) }
}
