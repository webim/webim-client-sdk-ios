//
//  WMDocumentDownloadManager.swift
//  Webim.Ru
//
//  Created by EVGENII Loshchenko on 01.11.2021.
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
import Foundation

protocol WMDocumentDownloadTaskDelegate: AnyObject {
    func updateFileDownloadProgress(downloadFileUrl: URL, progress: Float, localFileUrl: URL?)
    func fileDownloadFaild(downloadFileUrl: URL)
}

typealias DownloadDocumentListenerContainer = WMWeakReferenseContainer<WMDocumentDownloadTaskDelegate>

class WMDocumentDownloadTask: NSObject, URLSessionDelegate {
    
    private static var tasks = [URL: WMDocumentDownloadTask]()
    
    private var progressListeners = Set<DownloadDocumentListenerContainer>()
    private var urlSession: URLSession?
    private var downloadTask: URLSessionDownloadTask?
    var fileURL: URL
    private var localFileURL: URL?
    
    var localFileUrl: URL?
    var isDownloaded = false
    var fileSize: Int64
    
    static func documentDownloadTaskFor(url: URL, fileSize: Int64, delegate: WMDocumentDownloadTaskDelegate) -> WMDocumentDownloadTask {
        let task = tasks[url] ?? WMDocumentDownloadTask(url: url, fileSize: fileSize, delegate: delegate)
        tasks[url] = task
        task.progressListeners.insert(WMWeakReferenseContainer(delegate))
        return task
    }
    
    init(url: URL, fileSize: Int64, delegate: WMDocumentDownloadTaskDelegate?) {
        if let delegate = delegate {
            self.progressListeners.insert(WMWeakReferenseContainer(delegate))
        }
        self.fileURL = url
        self.fileSize = fileSize
        super.init()
        
        let urlMd5 = "\(url)".MD5() ?? "temp_file"
        let fileName = "\(urlMd5).\(url.lastPathComponent)"
        localFileUrl = createLocalFileUrl(fileName)
    }
    
    func isFileExist() -> Bool {
        var isCurrentFileDownloaded = false
        
        guard let filePath = localFileUrl?.path else { return false }
        
        isCurrentFileDownloaded = FileManager.default.fileExists(atPath: filePath)
        isDownloaded = isCurrentFileDownloaded
        return isCurrentFileDownloaded
    }
    
    func downloadFile() {
        
        if isFileExist() {
            self.sendProgressChangedEventFor(progress: 1, localFileUrl: localFileUrl)
        } else {
            
            let configuration = URLSessionConfiguration.default
            urlSession = URLSession(
                configuration: configuration,
                delegate: self,
                delegateQueue: nil
            )
            
            downloadTask = urlSession?.downloadTask(with: fileURL)
            downloadTask?.resume()
            
        }
    }
    
    func sendDownloadFailedEvent() {
        DispatchQueue.main.async {
            for listenerContainer in self.progressListeners {
                listenerContainer.getValue()?.fileDownloadFaild(downloadFileUrl: self.fileURL)
            }
            self.progressListeners = []
        }
    }
    
    func sendProgressChangedEventFor(progress: Float, localFileUrl: URL?) {
        DispatchQueue.main.async {
            for listenerContainer in self.progressListeners {
                listenerContainer.getValue()?.updateFileDownloadProgress(downloadFileUrl: self.fileURL, progress: progress, localFileUrl: localFileUrl)
            }
            if localFileUrl != nil {
                // remove all listeners when document is downloaded
                self.progressListeners = []
            } else {
                // filter released listeners
                self.progressListeners = self.progressListeners.filter { $0.getValue() != nil }
            }
        }
    }
    
    func createLocalFileUrl(_ fileName: String) -> URL? {
        guard let documentsDirectory = FileManager.default.urls(
            for: .cachesDirectory,
               in: .userDomainMask
        ).first
        else {
            print("no access to documents folder")
            return nil
        }
        return documentsDirectory.appendingPathComponent(fileName)
    }
}
// MARK: - URLSessionDownloadDelegate
extension WMDocumentDownloadTask: URLSessionDownloadDelegate {
    
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        guard let localFileUrl = self.localFileUrl else {
            print("localFileUrl error")
            return
            
        }
        let httpResponse = downloadTask.response as? HTTPURLResponse
        if httpResponse?.statusCode != 200 {
            sendDownloadFailedEvent()
            print("Server error")
            return
        }
        
        do {
            try FileManager.default.copyItem(at: location, to: localFileUrl)
        } catch let error {
            print("Copy Error: \(error.localizedDescription)")
        }
        
        // Delete original copy
        try? FileManager.default.removeItem(at: location)
        
        self.sendProgressChangedEventFor(progress: 1.0, localFileUrl: localFileUrl)
    }
    
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        if fileSize == -1 {
            self.sendProgressChangedEventFor(progress: 0.5, localFileUrl: nil)
            return
        }
        let progress = Float(totalBytesWritten) / Float(fileSize)
        self.sendProgressChangedEventFor(progress: progress, localFileUrl: nil)
    }
}
