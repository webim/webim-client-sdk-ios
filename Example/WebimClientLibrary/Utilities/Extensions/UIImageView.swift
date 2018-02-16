//
//  UIImageView.swift
//  WebimClientLibrary_Example
//
//  Created by Nikita Lazarev-Zubov on 13.10.17.
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

extension UIImageView {
    
    // MARK: - Methods
    public func loadImageAsynchronouslyFrom(url: URL,
                                            rounded: Bool = false,
                                            completion: ((_ image: UIImage) -> ())? = nil) {
        let request = URLRequest(url: url)
        
        print("Requesting image: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: request,
                                   completionHandler: { [weak self] (data, _, _) in
                                    if let data = data {
                                        DispatchQueue.main.async {
                                            if let image = UIImage(data: data) {
                                                var imageToSave = image
                                                
                                                if rounded {
                                                    imageToSave = imageToSave.roundImage()
                                                }
                                                
                                                self?.image = imageToSave
                                                
                                                if let completion = completion {
                                                    completion(imageToSave)
                                                }
                                            }
                                        }
                                    } else {
                                        return
                                    }
        }).resume()
    }
    
}
