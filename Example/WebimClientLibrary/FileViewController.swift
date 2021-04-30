//
//  FileViewController.swift
//  WebimClientLibrary_Example
//
//  Created by Eugene Ilyin on 30/09/2019.
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

import UIKit
import WebKit
import SnapKit
import CloudKit

class FileViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    // MARK: - Properties
    var fileDestinationURL: URL?
    
    // MARK: - Private properties
    private var contentWebView = WKWebView()
    
    private lazy var alertDialogHandler = UIAlertHandler(delegate: self)
    
    // MARK: - Outlets
    @IBOutlet weak var contentWebViewContainer: UIView!
    @IBOutlet weak var loadingStatusLabel: UILabel!
    @IBOutlet weak var loadingStatusIndicator: UIActivityIndicatorView!
    
    // MARK: - View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNewTopbar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItem()
        setupLoadingSubiews()
        setupContentWebView()
        loadData()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        setOldTopBar()
    }
    
    // MARK: - WKWebView methods
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard keyPath == "estimatedProgress",
            contentWebView.estimatedProgress == 1.0
            else { return }
        
        loadingStatusLabel.isHidden = true
        loadingStatusIndicator.stopAnimating()
        loadingStatusIndicator.isHidden = true
    }
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard navigationAction.navigationType == .linkActivated,
            let url = navigationAction.request.url,
            UIApplication.shared.canOpenURL(url) else {
            decisionHandler(.allow)
            return
        }
        
        UIApplication.shared.open(url)
        decisionHandler(.cancel)
    }

    // MARK: - Private methods
    private func setupNavigationItem() {
        /// Files App was presented in iOS 11.0
        guard #available(iOS 11.0, *) else { return }

        let rightButton = UIButton(type: .system)
        rightButton.frame = CGRect(x: 0.0, y: 0.0, width: 20.0, height: 20.0)
        rightButton.setBackgroundImage(saveImageButtonImage, for: .normal)
        rightButton.addTarget(
            self,
            action: #selector(saveButtonTapped),
            for: .touchUpInside
        )
        
        rightButton.snp.remakeConstraints { (make) -> Void in
            make.height.width.equalTo(25.0)
        }
        
        let rightBarButton = UIBarButtonItem(customView: rightButton)
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    private func setupLoadingSubiews() {
        loadingStatusLabel.text = "Loading File...".localized
        loadingStatusIndicator.startAnimating()
    }
    
    /// Workaround for iOS < 11.0
    private func setupContentWebView() {
        contentWebView.navigationDelegate = self
        contentWebView.allowsLinkPreview = true
        contentWebView.uiDelegate = self
        contentWebView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil
        )
        
        contentWebViewContainer.addSubview(contentWebView)
        contentWebViewContainer.sendSubviewToBack(contentWebView)
        
        configureConstraints()
    }
    
    private func configureConstraints() {
        contentWebView.translatesAutoresizingMaskIntoConstraints = false
        contentWebView.snp.makeConstraints { (make) in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
    }
    
    private func loadData() {
        guard let destinationURL = fileDestinationURL else { return }
        contentWebView.load(URLRequest(url: destinationURL))
    }
    
    private func setNewTopbar() {
        setTopBar(
            isEnabled: false,
            isTranslucent: true,
            barTintColor: topBarTintColourClear
        )
        
    }
    
    private func setOldTopBar() {
        setTopBar(
            isEnabled: true,
            isTranslucent: false,
            barTintColor: topBarTintColourDefault
        )
    }
    
    private func setTopBar(
        isEnabled: Bool,
        isTranslucent: Bool,
        barTintColor: UIColor
    ) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = isEnabled
        navigationController?.navigationBar.isTranslucent = isTranslucent
        navigationController?.navigationBar.barTintColor = barTintColor
    }
    
    @objc
    @available(iOS 11.0, *)
    private func saveButtonTapped(sender: UIBarButtonItem) {
        guard let fileDestinationURL = fileDestinationURL,
            let documentDirectory = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first else { return }
        
        let fileName = fileDestinationURL.lastPathComponent
        let savingURL = documentDirectory.appendingPathComponent(fileName)
        
        do {
            let data = try Data(contentsOf: fileDestinationURL)
            try data.write(to: savingURL)
            alertDialogHandler.showFileSavingSuccessDialog()
        } catch {
            alertDialogHandler.showFileSavingFailureDialog(withError: error)
        }
    }
}
