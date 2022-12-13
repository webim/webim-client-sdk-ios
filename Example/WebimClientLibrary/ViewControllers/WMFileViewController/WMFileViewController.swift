//
//  WMFileViewController.swift
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
import CoreServices

class WMFileViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    // MARK: - Properties
    var fileDestinationURL: URL?
    
    // MARK: - Private properties
    private var contentWebView = WKWebView()
    
    private lazy var alertDialogHandler = UIAlertHandler(delegate: self)
    private lazy var navigationControllerManager = NavigationControllerManager()

    // MARK: - Outlets
    @IBOutlet var contentWebViewContainer: UIView!
    @IBOutlet var loadingStatusLabel: UILabel!
    @IBOutlet var loadingStatusIndicator: UIActivityIndicatorView!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoadingSubiews()
        setupContentWebView()
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationItem()
        setupNavigationControllerManager()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        resetNavigationControllerManager()
    }
    
    @IBAction func saveFile(_ sender: Any) {
        guard let fileToSave = fileDestinationURL else { return }
        let ac = UIActivityViewController(activityItems: [fileToSave], applicationActivities: nil)
        self.present(ac, animated: true)
        ac.completionWithItemsHandler = { type, bool, _, error in
            if bool && (type == .saveToCameraRoll || type == .saveToFile) {
                let saveView = WMSaveView.loadXibView()
                self.view.addSubview(saveView)
                saveView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
                saveView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
                self.view.bringSubviewToFront(saveView)
                saveView.animateImage()
            }
            if let error = error {
                self.alertDialogHandler.showFileSavingFailureDialog(withError: error)
            }
        }
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
        rightButton.setBackgroundImage(fileShare, for: .normal)
        rightButton.addTarget(
            self,
            action: #selector(saveFile),
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

    private func setupNavigationControllerManager() {
        navigationControllerManager.setAdditionalHeight()
        navigationControllerManager.update(with: .defaultStyle, removeOriginBorder: true)
    }

    private func resetNavigationControllerManager() {
        if #available(iOS 11.0, *) {
            additionalSafeAreaInsets = .zero
        }
        navigationControllerManager.reset()
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
        contentWebView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.edges.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.edges.equalToSuperview()
            }
        }
    }
    
    private func loadData() {
        guard let destinationURL = fileDestinationURL else { return }
        contentWebView.load(URLRequest(url: destinationURL))
    }
}

