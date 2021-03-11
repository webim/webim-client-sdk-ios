//
//  SQLiteHistoryStorage.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 11.08.17.
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

import Foundation
import SQLite

/**
 Class that is responsible for history storage inside SQLite DB. Uses SQLite.swift library.
 - seealso:
 https://github.com/stephencelis/SQLite.swift
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2017 Webim
 */
final class SQLiteHistoryStorage: HistoryStorage {
    
    // MARK: - Constants
    
    // MARK: SQLite tables and columns names
    private enum TableName: String {
        case history = "history"
    }
    private enum ColumnName: String {
        // In DB columns order.
        case id = "id"
        case clientSideID = "client_side_id"
        case timestamp = "timestamp"
        case senderID = "sender_id"
        case senderName = "sender_name"
        case avatarURLString = "avatar_url_string"
        case type = "type"
        case text = "text"
        case data = "data"
        case canBeReplied = "can_be_replied"
        case quote = "quote"
    }
    
    // MARK: SQLite.swift abstractions
    
    private static let history = Table(TableName.history.rawValue)
    
    // In DB columns order.
    private static let id = Expression<String>(ColumnName.id.rawValue)
    private static let clientSideID = Expression<String?>(ColumnName.clientSideID.rawValue)
    private static let timestamp = Expression<Int64>(ColumnName.timestamp.rawValue)
    private static let senderID = Expression<String?>(ColumnName.senderID.rawValue)
    private static let senderName = Expression<String>(ColumnName.senderName.rawValue)
    private static let avatarURLString = Expression<String?>(ColumnName.avatarURLString.rawValue)
    private static let type = Expression<String>(ColumnName.type.rawValue)
    private static let text = Expression<String>(ColumnName.text.rawValue)
    private static let data = Expression<Blob?>(ColumnName.data.rawValue)
    private static let canBeReplied = Expression<Bool?>(ColumnName.canBeReplied.rawValue)
    private static let quote = Expression<Blob?>(ColumnName.quote.rawValue)
    
    
    // MARK: - Properties
    private static let queryQueue = DispatchQueue(label: "SQLiteHistoryStorageQueryQueue", qos: .background)
    private let completionHandlerQueue: DispatchQueue
    private let serverURLString: String
    private let fileUrlCreator: FileUrlCreator
    private var db: Connection?
    private var firstKnownTimestamp: Int64 = -1
    private var readBeforeTimestamp: Int64
    private var prepared = false
    private var reachedHistoryEnd: Bool
    
    
    // MARK: - Initialization
    init(dbName: String,
         serverURL serverURLString: String,
         fileUrlCreator: FileUrlCreator,
         reachedHistoryEnd: Bool,
         queue: DispatchQueue,
         readBeforeTimestamp: Int64) {
        self.serverURLString = serverURLString
        self.fileUrlCreator = fileUrlCreator
        self.reachedHistoryEnd = reachedHistoryEnd
        self.completionHandlerQueue = queue
        self.readBeforeTimestamp = readBeforeTimestamp
        
        createTableWith(name: dbName)
    }
    
    // MARK: - Methods
    
    // MARK: HistoryStorage protocol methods
    
    func getMajorVersion() -> Int {
        // No need in this implementation.
        return 7
    }
    
    func getVersionDB() -> Int {
        return 7
    }
    
    func set(reachedHistoryEnd: Bool) {
        self.reachedHistoryEnd = reachedHistoryEnd
    }
    
    func updateDB() {
        dropTables()
        createTables()
    }
    
    func getFullHistory(completion: @escaping ([Message]) -> ()) {
        SQLiteHistoryStorage.queryQueue.async { [weak self] in
            guard let `self` = self,
                let db = self.db else {
                return
            }
            
            /*
             SELECT * FROM history
             ORDER BY timestamp_in_microsecond ASC
             */
            let query = SQLiteHistoryStorage
                .history
                .order(SQLiteHistoryStorage.timestamp.asc)
            
            var messages = [MessageImpl]()
            
            do {
                for row in try db.prepare(query) {
                    let message = self.createMessageBy(row: row)
                    messages.append(message)
                    
                    db.trace {
                        WebimInternalLogger.shared.log(entry: "\($0)",
                            verbosityLevel: .debug)
                    }
                }
                
                self.completionHandlerQueue.async {
                    completion(messages as [Message])
                }
            } catch {
                WebimInternalLogger.shared.log(entry: error.localizedDescription,
                                               verbosityLevel: .warning)
            }
        }
    }
    
    func getLatestHistory(byLimit limitOfMessages: Int,
                          completion: @escaping ([Message]) -> ()) {
        SQLiteHistoryStorage.queryQueue.async { [weak self] in
            guard let `self` = self,
                let db = self.db else {
                return
            }
            
            /*
             SELECT * FROM history
             ORDER BY timestamp_in_microsecond DESC
             LIMIT limitOfMessages
             */
            let query = SQLiteHistoryStorage
                .history
                .order(SQLiteHistoryStorage.timestamp.desc)
                .limit(limitOfMessages)
            
            var messages = [MessageImpl]()
            
            do {
                for row in try db.prepare(query) {
                    let message = self.createMessageBy(row: row)
                    messages.append(message)
                }
                
                db.trace {
                    WebimInternalLogger.shared.log(entry: "\($0)",
                        verbosityLevel: .debug)
                }
                
                messages = messages.reversed()
                self.completionHandlerQueue.async {
                    completion(messages as [Message])
                }
            } catch {
                WebimInternalLogger.shared.log(entry: error.localizedDescription,
                                               verbosityLevel: .warning)
            }
        }
    }
    
    func getHistoryBefore(id: HistoryID,
                          limitOfMessages: Int,
                          completion: @escaping ([Message]) -> ()) {
        SQLiteHistoryStorage.queryQueue.async { [weak self] in
            guard let `self` = self,
                let db = self.db else {
                return
            }
            
            let beforeTimeInMicrosecond = id.getTimeInMicrosecond()
            
            /*
             SELECT * FROM history
             WHERE timestamp_in_microsecond < beforeTimeInMicrosecond
             ORDER BY timestamp_in_microsecond DESC
             LIMIT limitOfMessages
             */
            let query = SQLiteHistoryStorage
                .history
                .filter(SQLiteHistoryStorage.timestamp < beforeTimeInMicrosecond)
                .order(SQLiteHistoryStorage.timestamp.desc)
                .limit(limitOfMessages)
            
            var messages = [MessageImpl]()
            
            do {
                for row in try db.prepare(query) {
                    let message = self.createMessageBy(row: row)
                    messages.append(message)
                    
                    db.trace {
                        WebimInternalLogger.shared.log(entry: "\($0)",
                            verbosityLevel: .debug)
                    }
                }
                
                messages = messages.reversed()
                self.completionHandlerQueue.async {
                    completion(messages as [Message])
                }
            } catch {
                WebimInternalLogger.shared.log(entry: error.localizedDescription,
                                               verbosityLevel: .warning)
            }
        }
    }
    
    func receiveHistoryBefore(messages: [MessageImpl],
                              hasMoreMessages: Bool) {
        SQLiteHistoryStorage.queryQueue.async { [weak self] in
            guard let `self` = self,
                let db = self.db else {
                return
            }
            
            var newFirstKnownTimeInMicrosecond = Int64.max
            
            for message in messages {
                guard let messageHistorID = message.getHistoryID() else {
                    continue
                }
                newFirstKnownTimeInMicrosecond = min(newFirstKnownTimeInMicrosecond,
                                                     messageHistorID.getTimeInMicrosecond())
                do {
                    /*
                     INSERT OR FAIL
                     INTO history
                     (id, timestamp_in_microsecond, sender_id, sender_name, avatar_url_string, type, text, data)
                     VALUES
                     (message.getID(), messageHistorID.getTimeInMicrosecond(), message.getOperatorID(), message.getSenderName(), message.getSenderAvatarURLString(), MessageItem.MessageKind(messageType: message.getType()).rawValue, message.getRawText() ?? message.getText(), SQLiteHistoryStorage.convertToBlob(dictionary: message.getData()), SQLiteHistoryStorage.convertToBlob(quote: message.getQuote()))
                     */
                    let statement = try db.prepare("INSERT OR FAIL INTO history ("
                        + "\(SQLiteHistoryStorage.ColumnName.id.rawValue), "
                        + "\(SQLiteHistoryStorage.ColumnName.timestamp.rawValue), "
                        + "\(SQLiteHistoryStorage.ColumnName.senderID.rawValue), "
                        + "\(SQLiteHistoryStorage.ColumnName.senderName.rawValue), "
                        + "\(SQLiteHistoryStorage.ColumnName.avatarURLString.rawValue), "
                        + "\(SQLiteHistoryStorage.ColumnName.type.rawValue), "
                        + "\(SQLiteHistoryStorage.ColumnName.text.rawValue), "
                        + "\(SQLiteHistoryStorage.ColumnName.data.rawValue), "
                        + "\(SQLiteHistoryStorage.ColumnName.canBeReplied.rawValue), "
                        + "\(SQLiteHistoryStorage.ColumnName.quote.rawValue)) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)")
                    try statement.run(message.getID(),
                                      messageHistorID.getTimeInMicrosecond(),
                                      message.getOperatorID(),
                                      message.getSenderName(),
                                      message.getSenderAvatarURLString(),
                                      MessageItem.MessageKind(messageType: message.getType()).rawValue,
                                      message.getRawText() ?? message.getText(),
                                      SQLiteHistoryStorage.convertToBlob(dictionary: message.getRawData()),
                                      message.canBeReplied(),
                                      SQLiteHistoryStorage.convertToBlob(quote: message.getQuote()))
                    // Raw SQLite statement constructed because there's no way to implement INSERT OR FAIL query with SQLite.swift methods. Appropriate INSERT query can look like this:
                    /*try db.run(SQLiteHistoryStorage
                     .history
                     .insert(SQLiteHistoryStorage.id <- message.getID(),
                     SQLiteHistoryStorage.timestampInMicrosecond <- message.getTimeInMicrosecond(),
                     SQLiteHistoryStorage.senderID <- message.getOperatorID(),
                     SQLiteHistoryStorage.senderName <- message.getSenderName(),
                     SQLiteHistoryStorage.avatarURLString <- message.getSenderAvatarURLString(),
                     SQLiteHistoryStorage.type <- MessageItem.MessageKind(messageType: message.getType()).rawValue,
                     SQLiteHistoryStorage.text <- message.getText(),
                     SQLiteHistoryStorage.data <- SQLiteHistoryStorage.convertToBlob(dictionary: message.getData()),
                     SQLiteHistoryStorage.quote <- SQLiteHistoryStorage.convertToBlob(quote: message.getQuote())))*/
                    
                    db.trace {
                        WebimInternalLogger.shared.log(entry: "\($0)",
                            verbosityLevel: .debug)
                    }
                } catch {
                    WebimInternalLogger.shared.log(entry: error.localizedDescription,
                                                   verbosityLevel: .warning)
                }
            }
            
            if newFirstKnownTimeInMicrosecond != Int64.max {
                self.firstKnownTimestamp = newFirstKnownTimeInMicrosecond
            }
        }
    }
    
    func receiveHistoryUpdate(withMessages messages: [MessageImpl],
                              idsToDelete: Set<String>,
                              completion: @escaping (_ endOfBatch: Bool, _ messageDeleted: Bool, _ deletedMesageID: String?, _ messageChanged: Bool, _ changedMessage: MessageImpl?, _ messageAdded: Bool, _ addedMessage: MessageImpl?, _ idBeforeAddedMessage: HistoryID?) -> ()) {
        SQLiteHistoryStorage.queryQueue.sync { [weak self] in
            guard let `self` = self,
                let db = self.db else {
                return
            }
            
            self.prepare()
            
            var newFirstKnownTimestamp = Int64.max
            
            for message in messages {
                guard let messageHistorID = message.getHistoryID() else {
                    continue
                }
                
                if ((self.firstKnownTimestamp != -1)
                    && (messageHistorID.getTimeInMicrosecond() < self.firstKnownTimestamp))
                    && !self.reachedHistoryEnd {
                    continue
                }
                
                newFirstKnownTimestamp = min(newFirstKnownTimestamp,
                                             messageHistorID.getTimeInMicrosecond())
                
                do {
                    try self.insert(message: message)
                    
                    /*
                     SELECT *
                     FROM history
                     WHERE timestamp > message.getTimeInMicrosecond()
                     ORDER BY timestamp ASC
                     LIMIT 1
                     */
                    let postQuery = SQLiteHistoryStorage
                        .history
                        .filter(SQLiteHistoryStorage.timestamp > message.getTimeInMicrosecond())
                        .order(SQLiteHistoryStorage.timestamp.asc)
                        .limit(1)
                    do {
                        if let row = try db.pluck(postQuery) {
                            db.trace {
                                WebimInternalLogger.shared.log(entry: "\($0)",
                                    verbosityLevel: .debug)
                            }
                            
                            let nextMessage = self.createMessageBy(row: row)
                            guard let historyID = nextMessage.getHistoryID() else {
                                WebimInternalLogger.shared.log(entry: "Next message has not History ID in SQLiteHistoryStorage.\(#function)")
                                return
                            }
                            
                            completionHandlerQueue.async {
                                completion(false,
                                           false,
                                           nil,
                                           false,
                                           nil,
                                           true,
                                           message,
                                           historyID)
                            }
                        } else {
                            completionHandlerQueue.async {
                                completion(false,
                                           false,
                                           nil,
                                           false,
                                           nil,
                                           true,
                                           message,
                                           nil)
                            }
                        }
                    } catch let error {
                        WebimInternalLogger.shared.log(entry: error.localizedDescription,
                                                       verbosityLevel: .warning)
                    }
                } catch let Result.error(_, code, _) where code == SQLITE_CONSTRAINT {
                    do {
                        try update(message: message)
                        
                        completionHandlerQueue.async {
                            completion(false, false, nil, true, message, false, nil, nil)
                        }
                    } catch {
                        WebimInternalLogger.shared.log(entry: "Update received message: \(message.toString()) failed: \(error.localizedDescription)")
                    }
                } catch {
                    WebimInternalLogger.shared.log(entry: "Insert / update received message: \(message.toString()) failed: \(error.localizedDescription)")
                }
            } // End of `for message in messages`
            
            for idToDelete in idsToDelete {
                do {
                    try delete(messageDBid: idToDelete)
                    completionHandlerQueue.async {
                        completion(false, true, idToDelete, false, nil, false, nil, nil)
                    }
                } catch {
                    WebimInternalLogger.shared.log(entry: "Delete received message with id \"\(idToDelete)\" failed: \(error.localizedDescription)")
                }
            }
            
            if (firstKnownTimestamp == -1)
                && (newFirstKnownTimestamp != Int64.max) {
                firstKnownTimestamp = newFirstKnownTimestamp
            }
            
            self.completionHandlerQueue.async {
                completion(true, false, nil, false, nil, false, nil, nil)
            }
        }
    }
    
    func updateReadBeforeTimestamp(timestamp: Int64) {
        self.readBeforeTimestamp = timestamp
    }
    
    // MARK: Private methods
    
    private static func convertToBlob(dictionary: [String: Any?]?) -> Blob? {
        if let dictionary = dictionary {
            let data = NSKeyedArchiver.archivedData(withRootObject: dictionary)
            
            return data.datatypeValue
        }
        
        return nil
    }
    
    private static func convertToBlob(quote: Quote?) -> Blob? {
        if let quote = quote {
            let dictionary = QuoteItem.toDictionary(quote: quote)
            let data = NSKeyedArchiver.archivedData(withRootObject: dictionary)
            
            return data.datatypeValue
        }
        
        return nil
    }
    
    private func dropTables() {
        guard let db = self.db else {
            return
        }
        _ = try? db.run(SQLiteHistoryStorage.history.drop(ifExists: true))
    }
    
    private func createTableWith(name: String) {
        SQLiteHistoryStorage.queryQueue.sync { [weak self] in
            guard let `self` = self else {
                return
            }
            
            let fileManager = FileManager.default
            let optionalLibraryDirectory = try? fileManager.url(for: .libraryDirectory,
                                                                  in: .userDomainMask,
                                                                  appropriateFor: nil,
                                                                  create: false)
            guard let libraryPath = optionalLibraryDirectory else {
                WebimInternalLogger.shared.log(entry: "Error getting access to Library directory.",
                                               verbosityLevel: .verbose)
                return
            }
            let dbPath = "\(libraryPath)/\(name)"
            do  {
                let db = try Connection(dbPath)
                db.userVersion = 5
                db.busyTimeout = 1.0
                db.busyHandler() { tries in
                    if tries >= 3 {
                        return false
                    }
                    return true
                }
                self.db = db
                createTables()
            } catch {
                WebimInternalLogger.shared.log(entry: "Creating Connection(\(dbPath) failure in FAQSQLiteHistoryStorage.\(#function)")
                return
            }
        }
    }
    
    private func createTables() {
        guard let db = db else {
            WebimInternalLogger.shared.log(entry: "Failure in SQLiteHistoryStorage.\(#function) because Database is nil")
            return
        }
        
        /*
         CREATE TABLE history
         id TEXT PRIMARY KEY NOT NULL,
         client_side_id TEXT,
         timestamp_in_microsecond INTEGER NOT NULL,
         sender_id TEXT,
         sender_name TEXT NOT NULL,
         avatar_url_string TEXT,
         type TEXT NOT NULL,
         text TEXT NOT NULL,
         data TEXT,
         quote TEXT
         */
        _ = try? db.run(SQLiteHistoryStorage.history.create(ifNotExists: true) { t in
            t.column(SQLiteHistoryStorage.id,
                     primaryKey: true)
            t.column(SQLiteHistoryStorage.clientSideID)
            t.column(SQLiteHistoryStorage.timestamp)
            t.column(SQLiteHistoryStorage.senderID)
            t.column(SQLiteHistoryStorage.senderName)
            t.column(SQLiteHistoryStorage.avatarURLString)
            t.column(SQLiteHistoryStorage.type)
            t.column(SQLiteHistoryStorage.text)
            t.column(SQLiteHistoryStorage.data)
            t.column(SQLiteHistoryStorage.canBeReplied)
            t.column(SQLiteHistoryStorage.quote)
        })
        db.trace {
            WebimInternalLogger.shared.log(entry: "\($0)",
                verbosityLevel: .debug)
        }
        createIndex()
    }
    
    private func createIndex() {
        guard let db = db else {
            return
        }
        do {
            /*
             CREATE UNIQUE INDEX index_history_on_timestamp_in_microsecond
             ON history (time_since_in_microsecond)
             */
             try db.run(SQLiteHistoryStorage
                .history
                .createIndex(SQLiteHistoryStorage.timestamp,
                             unique: true,
                             ifNotExists: true))
        } catch {
            WebimInternalLogger.shared.log(entry: error.localizedDescription,
                                           verbosityLevel: .verbose)
        }
        
        db.trace {
            WebimInternalLogger.shared.log(entry: "\($0)",
                verbosityLevel: .debug)
        }
    }
    
    private func prepare() {
        guard let db = db else {
            return
        }
        if !prepared {
            prepared = true
            
            /*
             SELECT timestamp_in_microsecond
             FROM history
             ORDER BY timestamp_in_microsecond ASC
             LIMIT 1
             */
            let query = SQLiteHistoryStorage
                .history
                .select(SQLiteHistoryStorage.timestamp)
                .order(SQLiteHistoryStorage.timestamp.asc)
                .limit(1)
            
            do {
                if let row = try db.pluck(query) {
                    db.trace {
                        WebimInternalLogger.shared.log(entry: "\($0)",
                            verbosityLevel: .debug)
                    }
                    
                    firstKnownTimestamp = row[SQLiteHistoryStorage.timestamp]
                }
            } catch {
                WebimInternalLogger.shared.log(entry: error.localizedDescription,
                                               verbosityLevel: .warning)
            }
        }
    }
    
    private func createMessageBy(row: Row) -> MessageImpl {
        let id = row[SQLiteHistoryStorage.id]
        let clientSideID = row[SQLiteHistoryStorage.clientSideID]
        
        var rawText: String? = nil
        var text = row[SQLiteHistoryStorage.text]
        guard let messageKind = MessageItem.MessageKind(rawValue: row[SQLiteHistoryStorage.type]),
            let type = MessageMapper.convert(messageKind: messageKind) else {
                WebimInternalLogger.shared.log(entry: "Getting Message type from row failure in SQLiteHistoryStorage.\(#function)")
            fatalError("Getting Message type from row failure in SQLiteHistoryStorage.\(#function). Can not create MessageImpl object without type")
        }
        if (type == .fileFromOperator)
            || (type == .fileFromVisitor) {
            rawText = text
            text = ""
        }
        
        var rawData: [String: Any?]?
        if let dataValue = row[SQLiteHistoryStorage.data] {
            rawData = NSKeyedUnarchiver.unarchiveObject(with: Data.fromDatatypeValue(dataValue)) as? [String: Any?]
        }
        
        var attachment: FileInfo? = nil
        var attachments = [FileInfo]()
        if let rawText = rawText {
            attachments = FileInfoImpl.getAttachments(byFileUrlCreator: fileUrlCreator,
                                                      text: rawText)
            if attachments.isEmpty {
                attachment = FileInfoImpl.getAttachment(byFileUrlCreator: fileUrlCreator,
                                                        text: rawText)
                if let attachment = attachment {
                    attachments.append(attachment)
                }
            } else {
                attachment = attachments.first
            }
        }
        
        var data: MessageData?
        if let attachment = attachment {
            data = MessageDataImpl(attachment: MessageAttachmentImpl(fileInfo: attachment,
                                                                     filesInfo: attachments,
                                                                     state: .ready))
        }
        
        var keyboard: Keyboard? = nil
        var keyboardRequest: KeyboardRequest? = nil
        var sticker: Sticker?
        if let data = rawData {
            keyboard = KeyboardImpl.getKeyboard(jsonDictionary: data)
            keyboardRequest = KeyboardRequestImpl.getKeyboardRequest(jsonDictionary: data)
            sticker = StickerImpl.getSticker(jsonDictionary: data)
        }
        
        let canBeReplied = row[SQLiteHistoryStorage.canBeReplied] ?? false
        
        var quote: Quote?
        if let quoteValue = row[SQLiteHistoryStorage.quote],
            let data = NSKeyedUnarchiver.unarchiveObject(with: Data.fromDatatypeValue(quoteValue)) as? [String : Any?] {
                quote = QuoteImpl.getQuote(quoteItem: QuoteItem(jsonDictionary: data), messageAttachment: nil)
        }
        
        return MessageImpl(serverURLString: serverURLString,
                           id: (clientSideID ?? id),
                           keyboard: keyboard,
                           keyboardRequest: keyboardRequest,
                           operatorID: row[SQLiteHistoryStorage.senderID],
                           quote: quote,
                           senderAvatarURLString: row[SQLiteHistoryStorage.avatarURLString],
                           senderName: row[SQLiteHistoryStorage.senderName],
                           sticker: sticker,
                           type: type,
                           rawData: rawData,
                           data: data,
                           text: text,
                           timeInMicrosecond: row[SQLiteHistoryStorage.timestamp],
                           historyMessage: true,
                           internalID: id,
                           rawText: rawText,
                           read: row[SQLiteHistoryStorage.timestamp] <= readBeforeTimestamp || readBeforeTimestamp == -1,
                           messageCanBeEdited: false,
                           messageCanBeReplied: canBeReplied,
                           messageIsEdited: false)
    }
    
    private func insert(message: MessageImpl) throws {
        guard let db = db,
            let messageHistoryID = message.getHistoryID() else {
                return
        }
        
        /*
         INSERT INTO history (id,
         client_side_id,
         timestamp,
         sender_id,
         sender_name,
         avatar_url_string,
         type,
         text,
         data
         ) VALUES (
         historyID.getDBid(),
         message.getID(),
         timeInMicorsecond,
         message.getOperatorID(),
         message.getSenderName(),
         message.getSenderAvatarURLString(),
         MessageItem.MessageKind(messageType: message.getType()).rawValue,
         (message.getRawText() ?? message.getText()),
         SQLiteHistoryStorage.convertToBlob(dictionary: message.getData())))
         */
        try db.run(SQLiteHistoryStorage
            .history
            .insert(SQLiteHistoryStorage.id <- messageHistoryID.getDBid(),
                    SQLiteHistoryStorage.clientSideID <- message.getID(),
                    SQLiteHistoryStorage.timestamp <- messageHistoryID.getTimeInMicrosecond(),
                    SQLiteHistoryStorage.senderID <- message.getOperatorID(),
                    SQLiteHistoryStorage.senderName <- message.getSenderName(),
                    SQLiteHistoryStorage.avatarURLString <- message.getSenderAvatarURLString(),
                    SQLiteHistoryStorage.type <- MessageItem.MessageKind(messageType: message.getType()).rawValue,
                    SQLiteHistoryStorage.text <- (message.getRawText() ?? message.getText()),
                    SQLiteHistoryStorage.data <- SQLiteHistoryStorage.convertToBlob(dictionary: message.getRawData()),
                    SQLiteHistoryStorage.canBeReplied <- message.canBeReplied(),
                    SQLiteHistoryStorage.quote <- SQLiteHistoryStorage.convertToBlob(quote: message.getQuote())))
        
        db.trace {
            WebimInternalLogger.shared.log(entry: "\($0)",
                verbosityLevel: .debug)
        }
    }
    
    private func update(message: MessageImpl) throws {
        guard let db = db,
            let messageHistoryID = message.getHistoryID() else {
                return
        }
        
        /*
         UPDATE history
         SET (
         client_side_id = message.getID(),
         timestamp = messageHistoryID.getTimeInMicrosecond(),
         sender_id = message.getOperatorID(),
         sender_name = message.getSenderName(),
         avatar_url_string = message.getSenderAvatarURLString(),
         type = MessageItem.MessageKind(messageType: message.getType()).rawValue,
         text = (message.getRawText() ?? message.getText()),
         data = SQLiteHistoryStorage.convertToBlob(dictionary: message.getData()))
         WHERE id = messageHistoryID.getDBid()
         */
        try db.run(SQLiteHistoryStorage
            .history
            .where(SQLiteHistoryStorage.id == messageHistoryID.getDBid())
            .update(SQLiteHistoryStorage.clientSideID <- message.getID(),
                    SQLiteHistoryStorage.timestamp <- messageHistoryID.getTimeInMicrosecond(),
                    SQLiteHistoryStorage.senderID <- message.getOperatorID(),
                    SQLiteHistoryStorage.senderName <- message.getSenderName(),
                    SQLiteHistoryStorage.avatarURLString <- message.getSenderAvatarURLString(),
                    SQLiteHistoryStorage.type <- MessageItem.MessageKind(messageType: message.getType()).rawValue,
                    SQLiteHistoryStorage.text <- (message.getRawText() ?? message.getText()),
                    SQLiteHistoryStorage.data <- SQLiteHistoryStorage.convertToBlob(dictionary: message.getRawData()),
                    SQLiteHistoryStorage.canBeReplied <- message.canBeReplied(),
                    SQLiteHistoryStorage.quote <- SQLiteHistoryStorage.convertToBlob(quote: message.getQuote())))
        
        db.trace {
            WebimInternalLogger.shared.log(entry: "\($0)",
                verbosityLevel: .debug)
        }
    }
    
    private func delete(messageDBid: String) throws {
        guard let db = db else {
            return
        }
        try db.run(SQLiteHistoryStorage
            .history
            .where(SQLiteHistoryStorage.id == messageDBid)
            .delete())
        
        db.trace {
            WebimInternalLogger.shared.log(entry: "\($0)",
                verbosityLevel: .debug)
        }
    }
    
}

// MARK: -
extension Connection {
    
    // MARK: - Properties
    public var userVersion: Int32 {
        get {
            guard let version = try? scalar("PRAGMA user_version") as? Int64 else {
                WebimInternalLogger.shared.log(entry: "Getting current version failure in Connection.\(#function)")
                return Int32(-1)
            }
            return Int32(version)
        }
        set { _ = try? run("PRAGMA user_version = \(newValue)") }
    }
    
}
