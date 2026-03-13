//
//  ShareViewController.swift
//  WebimClientShare
//
//  Created by Anna Frolova on 05.09.2022.
//  Copyright © 2022 Webim. All rights reserved.
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

import SwiftUI
import UIKit
import WebimShare

class ShareViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // WMShareView Example
        let shareView = WMShareBuilder()
            .set(userDefaultsAppGroup: "group.WebimClient.Share")
            .set(keychainAccessGroupName: Bundle.main.infoDictionary!["keychainAppIdentifier"] as! String)
            .set(titleText: "Share to Chat".localized)
            .set(backgroundColor: Color(hex: "FFFFFF"))
            .set(fileNameColor: Color(hex: "15ACD2"))
            .set(fileInfoColor: Color(hex: "5C5F8A").opacity(0.6))
            .set(loadingFileIconColor: Color(hex: "5C5F8A").opacity(0.6))
            .set(loadedFileIconColor: Color(hex: "15ACD2"))
            .set(errorFileIconColor: Color(hex: "F44336"))
            .set(cancelButtonTitleColor: Color(hex: "15ACD2"))
            .set(extensionContext: self.extensionContext)
            .build()
        
        let hostingController = UIHostingController(rootView: shareView)
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
}
