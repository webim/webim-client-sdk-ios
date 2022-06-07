//
//  WMFileDownloadManager.swift
//  Webim.Ru
//
//  Created by EVGENII Loshchenko on 08.06.2021.
//  Copyright © 2021 _webim_. All rights reserved.
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

protocol WMFileDownloadProgressListener: AnyObject {
    func progressChanged(url: URL, progress: Float, image: UIImage?)
}

typealias DownloadListenerContainer = WMWeakReferenseContainer<WMFileDownloadProgressListener>

class WMFileDownloadManager: NSObject {
    
    public static var shared = WMFileDownloadManager()
    private var progressDictionary = [URL: Float]()
    private var listeners = [URL: Set<DownloadListenerContainer>]()
    
    static func dropListeners() {
        AppDelegate.checkMainThread()
        shared.listeners = [URL: Set<DownloadListenerContainer>]()
    }
    
    func addProgressListener(url: URL, listener: WMFileDownloadProgressListener) {
        AppDelegate.checkMainThread()
        if !listeners.containsKey(keySearch: url) {
            listeners[url] = Set<DownloadListenerContainer>()
        }
        listeners[url]?.insert(WMWeakReferenseContainer(listener))
    }
    
    func removeListener(listener: WMFileDownloadProgressListener, url: URL) {
        AppDelegate.checkMainThread()
        listeners[url] = listeners[url]?.filter { $0.getValue() != nil && $0.getValue() !== listener }
    }
    
    func sendProgressChangedEventFor(url: URL, progress: Float, image: UIImage?) {
        for listenerContainer in listeners[url] ?? [] {
            listenerContainer.getValue()?.progressChanged(url: url, progress: progress, image: image)
        }
        if image != nil {
            // remove all listeners when image is downloaded
            listeners[url] = nil
        } else {
            // filter released listeners
            listeners[url] = listeners[url]?.filter { $0.getValue() != nil }
        }
    }
    
    func subscribeForImage(url: URL, progressListener: WMFileDownloadProgressListener) {
        AppDelegate.checkMainThread()
        let request = ImageRequest(url: url)
        if let imageContainer = ImageCache.shared[request] {
            progressListener.progressChanged(url: url, progress: 1, image: imageContainer)
        } else {
            self.addProgressListener(url: url, listener: progressListener)

            progressListener.progressChanged(url: url, progress: progressDictionary[url] ?? 0, image: nil)

            Nuke.ImagePipeline.shared.loadImage(
                with: url,
                progress: { _, completed, total in
                    var progress = Float(1.0)
                    if total != 0 {
                        progress = Float(completed) / Float(total)
                    }
                    AppDelegate.checkMainThread()
                    self.progressDictionary[url] = progress
                    self.sendProgressChangedEventFor(url: url, progress: progress, image: nil)
                },
                completion: { _ in
                    AppDelegate.checkMainThread()
                    self.sendProgressChangedEventFor(url: url, progress: 1, image: ImageCache.shared[request])
                }
            )
        }
    }
}
