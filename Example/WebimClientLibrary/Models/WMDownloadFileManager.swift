//
//  DownloadFileManager.swift
//  WebimClientLibrary_Example
//
//  Created by EVGENII Loshchenko on 04.05.2021.
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

import UIKit
import Nuke
import WebimClientLibrary

protocol WMDownloadFileManagerDelegate: AnyObject {
    func updateImageDownloadProgress(url: URL, progress: Float, image: UIImage? )
}

class WMDownloadFileManager {
    
    private var fileGuidURLDictionary: [String: String] = (WMKeychainWrapper.standard.dictionary(forKey: WMKeychainWrapper.fileGuidURLDictionaryKey) as? [String: String]) ?? [:]
    
    private var delegatesSet = Set<WMWeakReferenseContainer<WMDownloadFileManagerDelegate>>()
    
    func addDelegate(delegate: WMDownloadFileManagerDelegate) {
        delegatesSet.insert(WMWeakReferenseContainer(delegate))
    }
    
    func removeDelegate(delegate: AnyObject) {
        delegatesSet = delegatesSet.filter { $0.getValue() != nil && $0.getValue() as AnyObject !== delegate }
    }
    
    static var shared = WMDownloadFileManager()
    
    func saveUrl(_ url: URL?, forGuid guid: String) {
        self.fileGuidURLDictionary[guid] = url?.absoluteString
        WMKeychainWrapper.standard.setDictionary(fileGuidURLDictionary, forKey: WMKeychainWrapper.fileGuidURLDictionaryKey)
    }
    
    var progressDictionary: [URL: Float] = [:]
    
    func progressForURL(_ url: URL?) -> Float {
        if let url = url {
            return progressDictionary[url] ?? 0
        }
        return 0
    }
    
    private func  expiredFromUrl(_ url: URL?) -> Int64 {
        return Int64(url?.queryParameters?["expires"] ?? "0") ?? 0
    }
    
    func imageForFileInfo(_ fileInfo: FileInfo?) -> UIImage? {
        return nil
    }
    
    func urlFromFileInfo(_ fileInfo: FileInfo?) -> URL? {
        guard let fileInfo = fileInfo else { return nil }
        
        if let guid = fileInfo.getGuid() {
            
            if let cachedUrlString = self.fileGuidURLDictionary[guid] {  // check url cached and not expired
                let url = URL(string: cachedUrlString)
                let expires = self.expiredFromUrl(url)
                if Int64(Date().timeIntervalSince1970) < expires {
                    return url
                } else {
                    self.saveUrl(fileInfo.getURL(), forGuid: guid)
                }
            } else {
                self.saveUrl(fileInfo.getURL(), forGuid: guid)
            }
            
            return URL(string: self.fileGuidURLDictionary[guid] ?? "")
        }
        return fileInfo.getURL()
    }
    
    func imageForUrl(_ url: URL) -> UIImage? {

        let request = ImageRequest(url: url)
        if let image = ImageCache.shared[request] {
            return image

        } else {

            Nuke.ImagePipeline.shared.loadImage(
                with: url,
                progress: { _, completed, total in
                    
                    self.delegatesSet = self.delegatesSet.filter { $0.getValue() != nil }
                    
                    self.delegatesSet.forEach { container in
                        container.getValue()?.updateImageDownloadProgress(
                            url: url,
                            progress: Float(total) == 0 ? 0 : Float(completed) / Float(total),
                            image: nil
                        )
                    }
                },
                completion: { _ in
                    self.delegatesSet = self.delegatesSet.filter { $0.getValue() != nil }
                    self.delegatesSet.forEach { container in
                        container.getValue()?.updateImageDownloadProgress(
                            url: url,
                            progress: 1,
                            image: ImageCache.shared[request]
                        )
                    }
                }
            )
        }

        return nil
    }
}
