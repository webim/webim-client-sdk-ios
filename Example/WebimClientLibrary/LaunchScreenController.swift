//
//  LaunchScreenController.swift
//  WebimClientLibrary_Example
//
//  Created by Eugene Ilyin on 12/09/2019.
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

// MARK: -
class LaunchScreenController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var progressBarView: UIProgressView!
    @IBOutlet weak var bottomTextLabel: UILabel!
    @IBOutlet weak var webimLogoImageView: UIImageView!
    
    // MARK: - Properties
    private let progress = Progress(totalUnitCount: 100)
    private var timer = Timer()
    
    // MARK: - View Life Cycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        timer = Timer.scheduledTimer(
            timeInterval: 0.02,
            target: self,
            selector: #selector(updateProgressBar),
            userInfo: nil,
            repeats: true
        )
        
        animateView()
    }
    
    // MARK: - Private methods
    @objc
    private func updateProgressBar(timer: Timer) {
        guard !self.progress.isFinished else {
            timer.invalidate()
            return
        }
        
        self.progress.completedUnitCount += 1
        self.progressBarView.setProgress(
            Float(self.progress.fractionCompleted),
            animated: true
        )
    }

    private func animateView() {
        UIView.animate(
            withDuration: 1,
            delay: 2.0,
            animations: {
                self.progressBarView.alpha = 0
                self.webimLogoImageView.alpha = 0
                self.bottomTextLabel.alpha = 0
            },
            completion: { _ in
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let vc = sb.instantiateInitialViewController()
                UIApplication.shared.keyWindow?.rootViewController = vc
            }
        )
    }
    
}
