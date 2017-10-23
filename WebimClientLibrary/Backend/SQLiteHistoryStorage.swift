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


final class SQLiteHistoryStorage: HistoryStorage {
    
    // MARK: - Constants
    
    
    // MARK: SQLite tables and columns names
    
    private enum TableName: String {
        case HISTORY = "history"
    }
    
    private enum ColumnName: String {
        // In DB columns order.
        case ID = "id"
        case CLIENT_SIDE_ID = "client_side_id"
        case TIME_SINCE_IN_MICROSECOND = "time_since_in_microsecond"
        case SENDER_ID = "sender_id"
        case SENDER_NAME = "sender_name"
        case AVATAR_URL_STRING = "avatar_url_string"
        case TYPE = "type"
        case TEXT = "text"
        case DATA = "data"
        case SERVER_DATA = "server_data" // Data field of ACTION_REQUEST type message.
    }
    
    
    // MARK: SQLite.swift abstractions
    
    private static let history = Table(TableName.HISTORY.rawValue)
    
    // In DB columns order.
    private static let id = Expression<String>(ColumnName.ID.rawValue)
    private static let clientSideID = Expression<String?>(ColumnName.CLIENT_SIDE_ID.rawValue)
    private static let timeSinceInMicrosecond = Expression<Int64>(ColumnName.TIME_SINCE_IN_MICROSECOND.rawValue)
    private static let senderID = Expression<String?>(ColumnName.SENDER_ID.rawValue)
    private static let senderName = Expression<String>(ColumnName.SENDER_NAME.rawValue)
    private static let avatarURLString = Expression<String?>(ColumnName.AVATAR_URL_STRING.rawValue)
    private static let type = Expression<String>(ColumnName.TYPE.rawValue)
    private static let text = Expression<String>(ColumnName.TEXT.rawValue)
    private static let data = Expression<String?>(ColumnName.DATA.rawValue)
    private static let serverData = Expression<Blob?>(ColumnName.SERVER_DATA.rawValue)
    
    
    // MARK: - Properties
    private let queue: DispatchQueue
    private let serverURLString: String
    private var db: Connection?
    private var firstKnownTimeInMicrosecond: Int64 = -1
    private var prepared: Bool?
    private var reachedHistoryEnd: Bool
    
    
    // MARK: - Initialization
    init(withName dbName: String,
          serverURL serverURLString: String,
          reachedHistoryEnd: Bool,
          queue: DispatchQueue) {
        self.serverURLString = serverURLString
        self.reachedHistoryEnd = reachedHistoryEnd
        self.queue = queue
        
        createTableWith(name: dbName)
    }
    
    // MARK: - Methods
    
    // MARK: HistoryStorage protocol methods
    func getMajorVersion() -> Int {
        return 1
    }
    
    func set(reachedHistoryEnd: Bool) {
        self.reachedHistoryEnd = reachedHistoryEnd
    }
    
    func getLatestBy(limitOfMessages: Int,
                     completion: @escaping ([Message]) throws -> ()) throws {
        DispatchQueue.global(qos: .background).async {
            /*
             SELECT * FROM history
             ORDER BY timeInMicrosecond DESC
             LIMIT limitOfMessages
             */
            let query = SQLiteHistoryStorage.history
                .order(SQLiteHistoryStorage.timeSinceInMicrosecond.desc)
                .limit(limitOfMessages)
            
            var messages = [MessageImpl]()
            
            do {
                for row in try self.db!.prepare(query) {
                    let message = SQLiteHistoryStorage.createMessageBy(row: row,
                                                                       serverURL: self.serverURLString)
                    messages.append(message)
                    
                    messages = messages.reversed()
                    self.run(messageList: messages,
                             completion: completion)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getBefore(id: HistoryID,
                   limitOfMessages: Int,
                   completion: @escaping ([Message]) throws -> ()) throws {
        DispatchQueue.global(qos: .background).async {
            let beforeTimeInMicrosecond = id.getTimeInMicrosecond()
            
            /*
             SELECT * FROM history
             WHERE timeInMicrosecond < beforeTimeInMicrosecond
             ORDER BY timeInMicrosecond DESC
             LIMIT limitOfMessages
             */
            let query = SQLiteHistoryStorage.history
                .filter(SQLiteHistoryStorage.timeSinceInMicrosecond < beforeTimeInMicrosecond)
                .order(SQLiteHistoryStorage.timeSinceInMicrosecond.desc)
                .limit(limitOfMessages)
            
            var messages = [MessageImpl]()
            
            do {
                for row in try self.db!.prepare(query) {
                    let message = SQLiteHistoryStorage.createMessageBy(row: row,
                                                                       serverURL: self.serverURLString)
                    messages.append(message)
                    
                    messages = messages.reversed()
                    self.run(messageList: messages,
                             completion: completion)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func receiveHistoryBefore(messages: [MessageImpl],
                              hasMoreMessages: Bool) {
        DispatchQueue.global(qos: .background).async {
            var newFirstKnownTimeInMicrosecond = Int64.max
            
            for message in messages {
                newFirstKnownTimeInMicrosecond = min(newFirstKnownTimeInMicrosecond,
                                                     (message.getHistoryID()?.getTimeInMicrosecond())!)
                do {
                    /*
                     INSERT INTO history
                     (id, timeInMicrosecond, senderID, senderName, avatarURLString, type, text, serverData)
                     VALUES
                     (message.getID(), message.getTimeInMicrosecond(), message.getOperatorID(), message.getSenderName(), message.getSenderAvatarURLString(), message.getType().rawValue, message.getText(), message.getData())
                     */
                    try self.db!.run(SQLiteHistoryStorage.history.insert(SQLiteHistoryStorage.id <- message.getID(),
                                                                         SQLiteHistoryStorage.timeSinceInMicrosecond <- message.getTimeInMicrosecond(),
                                                                         SQLiteHistoryStorage.senderID <- message.getOperatorID(),
                                                                         SQLiteHistoryStorage.senderName <- message.getSenderName(),
                                                                         SQLiteHistoryStorage.avatarURLString <- message.getSenderAvatarURLString(),
                                                                         SQLiteHistoryStorage.type <- message.getType().rawValue,
                                                                         SQLiteHistoryStorage.text <- message.getText(),
                                                                         SQLiteHistoryStorage.serverData <- SQLiteHistoryStorage.convertToBlob(dictionary: message.getData())))
                } catch {
                    print(error.localizedDescription)
                }
            }
            
            if newFirstKnownTimeInMicrosecond != Int64.max {
                self.firstKnownTimeInMicrosecond = newFirstKnownTimeInMicrosecond
            }
        }
    }
    
    func receiveHistoryUpdate(messages: [MessageImpl],
                              idsToDelete: Set<String>,
                              completion: @escaping (_ endOfBatch: Bool, _ messageDeleted: Bool, _ deletedMesageID: String?, _ messageChanged: Bool, _ changedMessage: MessageImpl?, _ messageAdded: Bool, _ addedMessage: MessageImpl?, _ idBeforeAddedMessage: HistoryID?) throws -> ()) throws {
        DispatchQueue.global(qos: .background).async {
            var newFirstKnownTimeInMicrosecond = Int64.max
            
            for message in messages {
                do {
                    let historyID = message.getHistoryID()
                    
                    if ((self.firstKnownTimeInMicrosecond != -1)
                        && ((historyID?.getTimeInMicrosecond())! < self.firstKnownTimeInMicrosecond))
                        && !self.reachedHistoryEnd {
                        continue
                    }
                    
                    newFirstKnownTimeInMicrosecond = min(newFirstKnownTimeInMicrosecond,
                                                         historyID?.getTimeInMicrosecond() ?? newFirstKnownTimeInMicrosecond)
                    
                    /*
                     UPDATE history
                     SET (
                     clientSideID = message.getID(),
                     timeInMicrosecond = message.getHistoryID()?.getTimeInMicrosecond(),
                     senderID = message.getOperatorID(),
                     senderName = message.getSenderName(),
                     avatarURLString = message.getSenderAvatarURLString(),
                     type = message.getType().rawValue,
                     text = message.getText(),
                     data = message.getHistoryID()?.getDBid())
                     serverData = message.getData()
                     WHERE id = message.getID()
                     */
                    if try self.db!.run(SQLiteHistoryStorage.history
                        .where(SQLiteHistoryStorage.id == message.getID())
                        .update(SQLiteHistoryStorage.clientSideID <- message.getID(),
                                SQLiteHistoryStorage.timeSinceInMicrosecond <- (message.getHistoryID()?.getTimeInMicrosecond())!,
                                SQLiteHistoryStorage.senderID <- message.getOperatorID(),
                                SQLiteHistoryStorage.senderName <- message.getSenderName(),
                                SQLiteHistoryStorage.avatarURLString <- message.getSenderAvatarURLString(),
                                SQLiteHistoryStorage.type <- message.getType().rawValue,
                                SQLiteHistoryStorage.text <- message.getText(),
                                SQLiteHistoryStorage.data <- message.getHistoryID()?.getDBid(),
                                SQLiteHistoryStorage.serverData <- SQLiteHistoryStorage.convertToBlob(dictionary: message.getData()))) > 0 {
                        self.runChanged(message: message,
                                        completion: completion)
                    } else {
                        /*
                         INSERT INTO history
                         (id, clientSideID, timeInMicrosecond, senderID, senderName, avatarURLString, type, text, data, serverData)
                         VALUES
                         (message.getID(), historyID?.getDBid(), message.getTimeInMicrosecond(), message.getOperatorID(), message.getSenderName(), message.getSenderAvatarURLString(), message.getType().rawValue, message.getText(), message.getHistoryID().getDBid(), message.getData())
                         */
                        /*
                         <...INSERT> OR FAIL <history...> missed
                         https://sqlite.org/lang_conflict.html
                         */
                        try self.db!.run(SQLiteHistoryStorage.history.insert(SQLiteHistoryStorage.id <- message.getID(),
                                                                             SQLiteHistoryStorage.clientSideID <- historyID?.getDBid(),
                                                                             SQLiteHistoryStorage.timeSinceInMicrosecond <- message.getTimeInMicrosecond(),
                                                                             SQLiteHistoryStorage.senderID <- message.getOperatorID(),
                                                                             SQLiteHistoryStorage.senderName <- message.getSenderName(),
                                                                             SQLiteHistoryStorage.avatarURLString <- message.getSenderAvatarURLString(),
                                                                             SQLiteHistoryStorage.type <- message.getType().rawValue,
                                                                             SQLiteHistoryStorage.text <- message.getText(),
                                                                             SQLiteHistoryStorage.data <- message.getHistoryID()?.getDBid(),
                                                                             SQLiteHistoryStorage.serverData <- SQLiteHistoryStorage.convertToBlob(dictionary: message.getData())))
                        
                        /*
                         SELECT * FROM history
                         WHERE timeInMicrosecond > message.getTimeInMicrosecond()
                         ORDER BY timeInMicrosecond ASC
                         LIMIT 1
                         */
                        let postQuery = SQLiteHistoryStorage.history
                            .filter(SQLiteHistoryStorage.timeSinceInMicrosecond > message.getTimeInMicrosecond())
                            .order(SQLiteHistoryStorage.timeSinceInMicrosecond.asc)
                            .limit(1)
                        
                        do {
                            if let row = try self.db!.pluck(postQuery) {
                                let nextMessage = SQLiteHistoryStorage.createMessageBy(row: row,
                                                                                       serverURL: self.serverURLString)
                                self.runAdded(message: message,
                                              beforeID: nextMessage.getHistoryID()!,
                                              completion: completion)
                            }
                        } catch {
                            self.runAdded(message: message,
                                          beforeID: nil,
                                          completion: completion)
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
            } // End of 'for message in messages'
            
            if (self.firstKnownTimeInMicrosecond == -1)
                && (newFirstKnownTimeInMicrosecond != Int64.max) {
                self.firstKnownTimeInMicrosecond = newFirstKnownTimeInMicrosecond
            }
            
            self.queue.async {
                do {
                    try completion(true, false, nil, false, nil, false, nil, nil)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    
    // MARK: Private methods
    
    private func createTableWith(name: String) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                .userDomainMask,
                                                                true).first!
        let dbPath = "\(documentsPath)/\(name)"
        db = try! Connection(dbPath)
        
        /*
         CREATE TABLE history
         id TEXT PRIMARY KEY NOT NULL,
         clientSideID TEXT,
         timeInMicrosecond INTEGER NOT NULL,
         senderID TEXT,
         senderName TEXT NOT NULL,
         avatarURLString TEXT,
         type TEXT NOT NULL,
         text TEXT NOT NULL,
         data TEXT,
         serverData TEXT
         */
        try! db?.run(SQLiteHistoryStorage.history.create(ifNotExists: true) { t in
            t.column(SQLiteHistoryStorage.id,
                     primaryKey: true)
            t.column(SQLiteHistoryStorage.clientSideID)
            t.column(SQLiteHistoryStorage.timeSinceInMicrosecond)
            t.column(SQLiteHistoryStorage.senderID)
            t.column(SQLiteHistoryStorage.senderName)
            t.column(SQLiteHistoryStorage.avatarURLString)
            t.column(SQLiteHistoryStorage.type)
            t.column(SQLiteHistoryStorage.text)
            t.column(SQLiteHistoryStorage.data)
            t.column(SQLiteHistoryStorage.serverData)
        })
        
        
        /*
         CREATE UNIQUE INDEX index_<history>_on_<timeInMicrosecond> 
         ON <history> (<timeInMicrosecond>)
         */
        _ = try? db?.run(SQLiteHistoryStorage.history.createIndex(SQLiteHistoryStorage.timeSinceInMicrosecond,
                                                                  unique: true))
    }
    
    private func prepareUpdate() {
        if self.prepared != true {
            self.prepared = true
            
            /*
             SELECT timeInMicrosecond
             FROM history
             ORDER BY timeInMicrosecond ASC
             LIMIT 1
             */
            let query = SQLiteHistoryStorage.history
                .select(SQLiteHistoryStorage.timeSinceInMicrosecond)
                .order(SQLiteHistoryStorage.timeSinceInMicrosecond.asc)
                .limit(1)
            
            do {
                if let row = try self.db!.pluck(query) {
                    self.firstKnownTimeInMicrosecond = row[SQLiteHistoryStorage.timeSinceInMicrosecond]
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func run(messageList: [MessageImpl],
                     completion: @escaping ([Message]) throws -> ()) {
        queue.async {
            do {
                try completion(messageList )
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func runAdded(message: MessageImpl,
                          beforeID: HistoryID?,
                          completion: @escaping (_ endOfBatch: Bool, _ messageDeleted: Bool, _ deletedMesageID: String?, _ messageChanged: Bool, _ changedMessage: MessageImpl?, _ messageAdded: Bool, _ addedMessage: MessageImpl?, _ idBeforeAddedMessage: HistoryID?) throws -> ()) {
        queue.async {
            do {
                try completion(false, false, nil, false, nil, true, message, beforeID)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func runChanged(message: MessageImpl,
                            completion: @escaping (_ endOfBatch: Bool, _ messageDeleted: Bool, _ deletedMesageID: String?, _ messageChanged: Bool, _ changedMessage: MessageImpl?, _ messageAdded: Bool, _ addedMessage: MessageImpl?, _ idBeforeAddedMessage: HistoryID?) throws -> ()) {
        queue.async {
            do {
                try completion(false, false, nil, true, message, false, nil, nil)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private static func createMessageBy(row: Row,
                                        serverURL: String) -> MessageImpl {
        let id = row[SQLiteHistoryStorage.id]
        let clientSideID = row[SQLiteHistoryStorage.clientSideID]
        
        var rawText: String? = nil
        var text = row[SQLiteHistoryStorage.text]
        let type = MessageType(rawValue: row[SQLiteHistoryStorage.type])
        if (type == MessageType.FILE_FROM_OPERATOR)
            || (type == MessageType.FILE_FROM_VISITOR) {
            rawText = text
            text = ""
        }
        
        var serverData: [String : Any?]?
        if let serverDataValue = row[SQLiteHistoryStorage.serverData] {
            serverData = NSKeyedUnarchiver.unarchiveObject(with: Data.fromDatatypeValue(serverDataValue)) as? [String : Any?]
        }
        
        
        var attachment: MessageAttachment? = nil
        if let rawText = rawText {
            attachment = MessageAttachmentImpl.getAttachment(byServerURL: serverURL,
                                                             text: rawText)
        }
        
        
        return MessageImpl(withServerURLString: serverURL,
                           id: (clientSideID == nil) ? id : clientSideID!,
                           operatorID: row[SQLiteHistoryStorage.senderID],
                           senderAvatarURLString: row[SQLiteHistoryStorage.avatarURLString],
                           senderName: row[SQLiteHistoryStorage.senderName],
                           type: type!,
                           data: serverData,
                           text: text,
                           timeInMicrosecond: row[SQLiteHistoryStorage.timeSinceInMicrosecond],
                           attachment: attachment,
                           historyMessage: true,
                           internalID: id,
                           rawText: rawText)
        
    }
    
    private static func convertToBlob(dictionary: [String : Any?]?) -> Blob? {
        if let dictionary = dictionary {
            let data = NSKeyedArchiver.archivedData(withRootObject: dictionary)
            
            return data.datatypeValue
        }
        
        return nil
    }
    
}
