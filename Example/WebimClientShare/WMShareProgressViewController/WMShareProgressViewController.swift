//
//  WMShareProgressViewController.swift
//  WebimClientShare
//
//  Created by Anna Frolova on 11.03.2024.
//  Copyright © 2024 Webim. All rights reserved.
//

import Foundation
import UIKit
import WebimMobileSDK

class WMShareProgressViewController: UIViewController {

    @IBOutlet var tableView: UITableView!

    var sendingFiles = [SendingFile]()
    private lazy var byteCountFormatter = byteFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableViewIndicatorInset()
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        closeExtension()
    }

    func startProgress(for sendingFile: SendingFile, with progress: Int? = 0) {

        if !sendingFileExist(sendingFile) {
            sendingFiles.append(sendingFile)
            let indexForInsert = IndexPath(row: sendingFiles.count - 1, section: 0)
            tableView.insertRows(at: [indexForInsert], with: .bottom)
        } else {
            let index = indexPathForSendingFile(sendingFile)
            tableView.reloadRows(at: [index], with: .none)
        }
    }

    func stateChanged(for sendingFile: SendingFile, with state: MessageSendStatus) {
        let index = indexForSendingFile(sendingFile)
        let indexPath = indexPathForSendingFile(sendingFile)
        sendingFiles[index].state = state
        tableView.reloadRows(at: [indexPath], with: .none)
        if sendingFiles.last?.state == .sent {
            closeExtension()
        }
    }

    private func closeExtension() {
        extensionContext?.completeRequest(
            returningItems: nil,
            completionHandler: nil
        )
    }

    private func indexForSendingFile(_ sendingFile: SendingFile) -> Int {
        return sendingFiles.firstIndex(where: { $0.fileID == sendingFile.fileID}) ?? 0
    }

    private func indexPathForSendingFile(_ sendingFile: SendingFile) -> IndexPath {
        let index = indexForSendingFile(sendingFile)
        return IndexPath(row: index, section: 0)
    }

    private func sendingFileExist(_ sendingFile: SendingFile) -> Bool {
        sendingFiles.first(where: { $0.fileID == sendingFile.fileID}) != nil
    }

    private func generateProgressInfo(for sendingFile: SendingFile) -> String {
        let sizeSent = byteCountFormatter.string(fromByteCount: sendingFile.totalBytesSent)
        let size = byteCountFormatter.string(fromByteCount: sendingFile.totalBytes)
        return "\(sizeSent) / \(size)"
    }

    private func registerCellIfNeeded() {
        let identifier = "\(ShareProgressTableViewCell.self)"

        if !tableView.identifierRegistered(identifier) {
            tableView.registerCellWithType(ShareProgressTableViewCell.self)
        }
    }

    private func byteFormatter() -> ByteCountFormatter {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = .useAll
        formatter.countStyle = .file
        formatter.includesUnit = true
        formatter.isAdaptive = true
        return formatter
    }

    private func setupTableViewIndicatorInset() {
        tableView.scrollIndicatorInsets = UIEdgeInsets(
            top: 10,
            left: 0,
            bottom: 10,
            right: 20
        )
    }
}

extension WMShareProgressViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sendingFiles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        registerCellIfNeeded()
        let cell = tableView.dequeueReusableCellWithType(ShareProgressTableViewCell.self)
        let currentFile = sendingFiles[indexPath.row]
        cell.setupIndicator()
        cell.setFileName(currentFile.fileName)
        cell.setState(currentFile.state)
//        cell.setProgress(currentFile.progress)
//        cell.setProgressInfo(generateProgressInfo(for: currentFile))
        return cell
    }
}
