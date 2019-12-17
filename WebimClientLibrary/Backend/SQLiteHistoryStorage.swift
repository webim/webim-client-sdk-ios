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
    private static let quote = Expression<Blob?>(ColumnName.quote.rawValue)
    
    
    // MARK: - Properties
    private static let queryQueue = DispatchQueue(label: "SQLiteHistoryStorageQueryQueue", qos: .background)
    private let completionHandlerQueue: DispatchQueue
    private let serverURLString: String
    private let webimClient: WebimClient
    private var db: Connection?
    private var firstKnownTimestamp: Int64 = -1
    private var readBeforeTimestamp: Int64
    private var prepared = false
    private var reachedHistoryEnd: Bool
    
    
    // MARK: - Initialization
    init(dbName: String,
         serverURL serverURLString: String,
         webimClient: WebimClient,
         reachedHistoryEnd: Bool,
         queue: DispatchQueue,
         readBeforeTimestamp: Int64) {
        self.serverURLString = serverURLString
        self.webimClient = webimClient
        self.reachedHistoryEnd = reachedHistoryEnd
        self.completionHandlerQueue = queue
        self.readBeforeTimestamp = readBeforeTimestamp
        
        createTableWith(name: dbName)
    }
    
    // MARK: - Methods
    
    // MARK: HistoryStorage protocol methods
    
    func getMajorVersion() -> Int {
        // No need in this implementation.
        return 4
    }
    
    func getVersionDB() -> Int {
        return 4
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
            guard let `self` = self else {
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
                for row in try self.db!.prepare(query) {
                    let message = self.createMessageBy(row: row)
                    messages.append(message)
                    
                    self.db?.trace {
                        WebimInternalLogger.shared.log(entry: "\($0)",
                            verbosityLevel: .DEBUG)
                    }
                }
                
                self.completionHandlerQueue.async {
                    completion(messages as [Message])
                }
            } catch {
                WebimInternalLogger.shared.log(entry: error.localizedDescription,
                                               verbosityLevel: .WARNING)
            }
        }
    }
    
    func getLatestHistory(byLimit limitOfMessages: Int,
                          completion: @escaping ([Message]) -> ()) {
        SQLiteHistoryStorage.queryQueue.async { [weak self] in
            guard let `self` = self else {
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
                for row in try self.db!.prepare(query) {
                    let message = self.createMessageBy(row: row)
                    messages.append(message)
                }
                
                self.db?.trace {
                    WebimInternalLogger.shared.log(entry: "\($0)",
                        verbosityLevel: .DEBUG)
                }
                
                messages = messages.reversed()
                self.completionHandlerQueue.async {
                    completion(messages as [Message])
                }
            } catch {
                WebimInternalLogger.shared.log(entry: error.localizedDescription,
                                               verbosityLevel: .WARNING)
            }
        }
    }
    
    func getHistoryBefore(id: HistoryID,
                          limitOfMessages: Int,
                          completion: @escaping ([Message]) -> ()) {
        SQLiteHistoryStorage.queryQueue.async { [weak self] in
            guard let `self` = self else {
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
                for row in try self.db!.prepare(query) {
                    let message = self.createMessageBy(row: row)
                    messages.append(message)
                    
                    self.db?.trace {
                        WebimInternalLogger.shared.log(entry: "\($0)",
                            verbosityLevel: .DEBUG)
                    }
                }
                
                messages = messages.reversed()
                self.completionHandlerQueue.async {
                    completion(messages as [Message])
                }
            } catch {
                WebimInternalLogger.shared.log(entry: error.localizedDescription,
                                               verbosityLevel: .WARNING)
            }
        }
    }
    
    func receiveHistoryBefore(messages: [MessageImpl],
                              hasMoreMessages: Bool) {
        SQLiteHistoryStorage.queryQueue.async { [weak self] in
            guard let `self` = self else {
                return
            }
            
            var newFirstKnownTimeInMicrosecond = Int64.max
            
            for message in messages {
                newFirstKnownTimeInMicrosecond = min(newFirstKnownTimeInMicrosecond,
                                                     message.getHistoryID()!.getTimeInMicrosecond())
                do {
                    /*
                     INSERT OR FAIL
                     INTO history
                     (id, timestamp_in_microsecond, sender_id, sender_name, avatar_url_string, type, text, data)
                     VALUES
                     (message.getID(), message.getHistoryID()!.getTimeInMicrosecond(), message.getOperatorID(), message.getSenderName(), message.getSenderAvatarURLString(), MessageItem.MessageKind(messageType: message.getType()).rawValue, message.getRawText() ?? message.getText(), SQLiteHistoryStorage.convertToBlob(dictionary: message.getData()), SQLiteHistoryStorage.convertToBlob(quote: message.getQuote()))
                     */
                    let statement = try self.db!.prepare("INSERT OR FAIL INTO history ("
                        + "\(SQLiteHistoryStorage.ColumnName.id.rawValue), "
                        + "\(SQLiteHistoryStorage.ColumnName.timestamp.rawValue), "
                        + "\(SQLiteHistoryStorage.ColumnName.senderID.rawValue), "
                        + "\(SQLiteHistoryStorage.ColumnName.senderName.rawValue), "
                        + "\(SQLiteHistoryStorage.ColumnName.avatarURLString.rawValue), "
                        + "\(SQLiteHistoryStorage.ColumnName.type.rawValue), "
                        + "\(SQLiteHistoryStorage.ColumnName.text.rawValue), "
                        + "\(SQLiteHistoryStorage.ColumnName.data.rawValue), "
                        + "\(SQLiteHistoryStorage.ColumnName.quote.rawValue)) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)")
                    try statement.run(message.getID(),
                                      message.getHistoryID()!.getTimeInMicrosecond(),
                                      message.getOperatorID(),
                                      message.getSenderName(),
                                      message.getSenderAvatarURLString(),
                                      MessageItem.MessageKind(messageType: message.getType()).rawValue,
                                      message.getRawText() ?? message.getText(),
                                      SQLiteHistoryStorage.convertToBlob(dictionary: message.getData()),
                                      SQLiteHistoryStorage.convertToBlob(quote: message.getQuote()))
                    // Raw SQLite statement constructed because there's no way to implement INSERT OR FAIL query with SQLite.swift methods. Appropriate INSERT query can look like this:
                    /*try self.db!.run(SQLiteHistoryStorage
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
                    
                    self.db?.trace {
                        WebimInternalLogger.shared.log(entry: "\($0)",
                            verbosityLevel: .DEBUG)
                    }
                } catch {
                    WebimInternalLogger.shared.log(entry: error.localizedDescription,
                                                   verbosityLevel: .WARNING)
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
            guard let `self` = self else {
                return
            }
            
            self.prepare()
            
            var newFirstKnownTimestamp = Int64.max
            
            for message in messages {
                guard message.getHistoryID() != nil else {
                    continue
                }
                
                if ((self.firstKnownTimestamp != -1)
                    && (message.getHistoryID()!.getTimeInMicrosecond() < self.firstKnownTimestamp))
                    && !self.reachedHistoryEnd {
                    continue
                }
                
                newFirstKnownTimestamp = min(newFirstKnownTimestamp,
                                             message.getHistoryID()!.getTimeInMicrosecond())
                
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
                        if let row = try self.db!.pluck(postQuery) {
                            self.db?.trace {
                                WebimInternalLogger.shared.log(entry: "\($0)",
                                    verbosityLevel: .DEBUG)
                            }
                            
                            let nextMessage = self.createMessageBy(row: row)
                            completionHandlerQueue.async {
                                completion(false,
                                           false,
                                           nil,
                                           false,
                                           nil,
                                           true,
                                           message,
                                           nextMessage.getHistoryID()!)
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
                                                       verbosityLevel: .WARNING)
                    }
                } catch let Result.error(_, code, _) where code == SQLITE_CONSTRAINT {
                    do {
                        try update(message: message)
                        
                        completionHandlerQueue.async {
                            completion(false, false, nil, true, message, false, nil, nil)
                        }
                    } catch {
                        WebimInternalLogger.shared.log(entry: "Update received message: \(message.toString()) failed: \(error.localizedDescription)",
                            verbosityLevel: .ERROR)
                    }
                } catch {
                    WebimInternalLogger.shared.log(entry: "Insert / update received message: \(message.toString()) failed: \(error.localizedDescription)",
                        verbosityLevel: .ERROR)
                }
            } // End of `for message in messages`
            
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
        try! self.db?.run(SQLiteHistoryStorage.history.drop(ifExists: true))
    }
    
    private func createTableWith(name: String) {
        SQLiteHistoryStorage.queryQueue.sync { [weak self] in
            guard let `self` = self else {
                return
            }
            
            let fileManager = FileManager.default
            let documentsPath = try! fileManager.url(for: .documentDirectory,
                                                     in: .userDomainMask,
                                                     appropriateFor: nil,
                                                     create: false)
            let dbPath = "\(documentsPath)/\(name)"
            self.db = try! Connection(dbPath)
            self.db?.userVersion = 4
            self.db?.busyTimeout = 1.0
            self.db?.busyHandler() { tries in
                if tries >= 3 {
                    return false
                }
                
                return true
            }
            
            createTables()
        }
    }
    
    private func createTables() {
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
        try! self.db?.run(SQLiteHistoryStorage.history.create(ifNotExists: true) { t in
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
            t.column(SQLiteHistoryStorage.quote)
        })
        self.db?.trace {
            WebimInternalLogger.shared.log(entry: "\($0)",
                verbosityLevel: .DEBUG)
        }
        createIndex()
    }
    
    private func createIndex() {
        do {
            /*
             CREATE UNIQUE INDEX index_history_on_timestamp_in_microsecond
             ON history (time_since_in_microsecond)
             */
            _ = try db?.run(SQLiteHistoryStorage
                .history
                .createIndex(SQLiteHistoryStorage.timestamp,
                             unique: true,
                             ifNotExists: true))
        } catch {
            WebimInternalLogger.shared.log(entry: error.localizedDescription,
                                           verbosityLevel: .VERBOSE)
        }
        
        db?.trace {
            WebimInternalLogger.shared.log(entry: "\($0)",
                verbosityLevel: .DEBUG)
        }
    }
    
    private func prepare() {
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
                if let row = try self.db!.pluck(query) {
                    db?.trace {
                        WebimInternalLogger.shared.log(entry: "\($0)",
                            verbosityLevel: .DEBUG)
                    }
                    
                    firstKnownTimestamp = row[SQLiteHistoryStorage.timestamp]
                }
            } catch {
                WebimInternalLogger.shared.log(entry: error.localizedDescription,
                                               verbosityLevel: .WARNING)
            }
        }
    }
    
    private func createMessageBy(row: Row) -> MessageImpl {
        let id = row[SQLiteHistoryStorage.id]
        let clientSideID = row[SQLiteHistoryStorage.clientSideID]
        
        var rawText: String? = nil
        var text = row[SQLiteHistoryStorage.text]
        let type = MessageMapper.convert(messageKind: MessageItem.MessageKind(rawValue: row[SQLiteHistoryStorage.type])!)
        if (type == .FILE_FROM_OPERATOR)
            || (type == .FILE_FROM_VISITOR) {
            rawText = text
            text = ""
        }
        
        var data: [String: Any?]?
        if let dataValue = row[SQLiteHistoryStorage.data] {
            data = NSKeyedUnarchiver.unarchiveObject(with: Data.fromDatatypeValue(dataValue)) as? [String: Any?]
        }
        
        
        var attachment: MessageAttachment? = nil
        if let rawText = rawText {
            attachment = MessageAttachmentImpl.getAttachment(byServerURL: serverURLString,
                                                             webimClient: webimClient,
                                                             text: rawText)
        }
        
        var keyboard: Keyboard? = nil
        if let data = data {
            keyboard = KeyboardImpl.getKeyboard(jsonDictionary: data)
        }
        
        var keyboardRequest: KeyboardRequest? = nil
        if let data = data {
            keyboardRequest = KeyboardRequestImpl.getKeyboardRequest(jsonDictionary: data)
        }
        
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
                           type: type!,
                           data: data,
                           text: text,
                           timeInMicrosecond: row[SQLiteHistoryStorage.timestamp],
                           attachment: attachment,
                           historyMessage: true,
                           internalID: id,
                           rawText: rawText,
                           read: row[SQLiteHistoryStorage.timestamp] <= readBeforeTimestamp || readBeforeTimestamp == -1,
                           messageCanBeEdited: false,
                           messageCanBeReplied: false)
    }
    
    private func insert(message: MessageImpl) throws {
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
        try db?.run(SQLiteHistoryStorage
            .history
            .insert(SQLiteHistoryStorage.id <- message.getHistoryID()!.getDBid(),
                    SQLiteHistoryStorage.clientSideID <- message.getID(),
                    SQLiteHistoryStorage.timestamp <- message.getHistoryID()!.getTimeInMicrosecond(),
                    SQLiteHistoryStorage.senderID <- message.getOperatorID(),
                    SQLiteHistoryStorage.senderName <- message.getSenderName(),
                    SQLiteHistoryStorage.avatarURLString <- message.getSenderAvatarURLString(),
                    SQLiteHistoryStorage.type <- MessageItem.MessageKind(messageType: message.getType()).rawValue,
                    SQLiteHistoryStorage.text <- (message.getRawText() ?? message.getText()),
                    SQLiteHistoryStorage.data <- SQLiteHistoryStorage.convertToBlob(dictionary: message.getData()),
                    SQLiteHistoryStorage.quote <- SQLiteHistoryStorage.convertToBlob(quote: message.getQuote())))
        
        db?.trace {
            WebimInternalLogger.shared.log(entry: "\($0)",
                verbosityLevel: .DEBUG)
        }
    }
    
    private func update(message: MessageImpl) throws {
        /*
         UPDATE history
         SET (
         client_side_id = message.getID(),
         timestamp = message.getHistoryID()!.getTimeInMicrosecond(),
         sender_id = message.getOperatorID(),
         sender_name = message.getSenderName(),
         avatar_url_string = message.getSenderAvatarURLString(),
         type = MessageItem.MessageKind(messageType: message.getType()).rawValue,
         text = (message.getRawText() ?? message.getText()),
         data = SQLiteHistoryStorage.convertToBlob(dictionary: message.getData()))
         WHERE id = message.getHistoryID()!.getDBid()
         */
        try db!.run(SQLiteHistoryStorage
            .history
            .where(SQLiteHistoryStorage.id == message.getHistoryID()!.getDBid())
            .update(SQLiteHistoryStorage.clientSideID <- message.getID(),
                    SQLiteHistoryStorage.timestamp <- message.getHistoryID()!.getTimeInMicrosecond(),
                    SQLiteHistoryStorage.senderID <- message.getOperatorID(),
                    SQLiteHistoryStorage.senderName <- message.getSenderName(),
                    SQLiteHistoryStorage.avatarURLString <- message.getSenderAvatarURLString(),
                    SQLiteHistoryStorage.type <- MessageItem.MessageKind(messageType: message.getType()).rawValue,
                    SQLiteHistoryStorage.text <- (message.getRawText() ?? message.getText()),
                    SQLiteHistoryStorage.data <- SQLiteHistoryStorage.convertToBlob(dictionary: message.getData()),
                    SQLiteHistoryStorage.quote <- SQLiteHistoryStorage.convertToBlob(quote: message.getQuote())))
        
        db?.trace {
            WebimInternalLogger.shared.log(entry: "\($0)",
                verbosityLevel: .DEBUG)
        }
    }
    
}

// MARK: -
extension Connection {
    
    // MARK: - Properties
    public var userVersion: Int32 {
        get { return Int32(try! scalar("PRAGMA user_version") as! Int64) }
        set { try! run("PRAGMA user_version = \(newValue)") }
    }
    
}
