//
//  SelectVisitorViewController.swift
//  WebimClientLibrary_Example
//
//  Created by Аслан Кутумбаев on 24.04.2023.
//  Copyright © 2023 Webim. All rights reserved.
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

protocol SelectVisitorDelegate: AnyObject {
    func didSelect(visitor: SelectVisitorViewController.VisitorRows)
    func controllerWillDisappear()
}

class SelectVisitorViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    weak var delegate: SelectVisitorDelegate?
    
    var dataSource: [VisitorRows] = [
        .unauthorized,
        .fedor,
        .semion
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.controllerWillDisappear()
    }
    
    func initialSetup() {
        modalPresentationStyle = .popover
        preferredContentSize = CGSize(width: view.bounds.width, height: 180)
        presentationController?.delegate = self
    }
    
    func set(delegate: SelectVisitorDelegate) {
        self.delegate = delegate
    }
    
    func set(sourceView: UIView) {
        popoverPresentationController?.canOverlapSourceViewRect = false
        popoverPresentationController?.sourceView = sourceView
        popoverPresentationController?.sourceRect = sourceView.bounds
    }
    
    func setArrowDirection(arrowDirection: UIPopoverArrowDirection) {
        popoverPresentationController?.permittedArrowDirections = arrowDirection
    }
}

extension SelectVisitorViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "defaultVisitorCell"
        var resultCell: UITableViewCell
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            resultCell = cell
        } else {
            resultCell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        
        configureCell(cell: resultCell, for: indexPath)
        
        return resultCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    private func configureCell(cell: UITableViewCell ,for indexPath: IndexPath) {
        let backgroundColor: UIColor = (indexPath.row % 2).isMultiple(of: 2) ? evenUserTableViewCellColor : oddUserTableViewCellColor
        
        cell.textLabel?.text = dataSource[indexPath.row].rawValue.localized
        cell.textLabel?.textColor = userTextLabelColor
        cell.textLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        cell.selectionStyle = .none
        cell.backgroundColor = backgroundColor
    }
    
    enum VisitorRows: String {
        case unauthorized = "Unauthorized"
        case fedor = "Fedor"
        case semion = "Semion"
    }
}

extension SelectVisitorViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelect(visitor: dataSource[indexPath.row])
        dismiss(animated: true)
    }
}

extension SelectVisitorViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }

    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.containerView?.layer.shadowColor = UIColor.black.cgColor
        popoverPresentationController.containerView?.layer.shadowRadius = 7
        popoverPresentationController.containerView?.layer.shadowOpacity = 0.6
        popoverPresentationController.containerView?.layer.shadowOffset = CGSize(width: 0, height: 1)
    }
}
