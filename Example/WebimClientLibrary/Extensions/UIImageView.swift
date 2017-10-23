//
//  UIImageView.swift
//  WebimClientLibrary_Example
//
//  Created by Nikita Lazarev-Zubov on 13.10.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    /**
     Asynchronously load an image to current UIImageView.
     Use `someImageView.loadImageAsynchronouslyFrom(url: someURL)`.
     - parameter url:
     URL of an image.
     - parameter rounded:
     Optional. Shows to a func if it has to round loaded image.
     - parameter completion:
     Optional. Completion that has to be called on loaded image when loading is finished.
     */
    public func loadImageAsynchronouslyFrom(url: URL,
                                            rounded: Bool = false,
                                            completion: ((UIImage) -> ())? = nil) {
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request,
                                   completionHandler: { data, _, _ in
                                    if let data = data {
                                        DispatchQueue.main.async {
                                            if let image = UIImage(data: data) {
                                                var imageToSave = image
                                                
                                                if rounded {
                                                    imageToSave = imageToSave.roundImage()
                                                }
                                                
                                                self.image = imageToSave
                                                
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

