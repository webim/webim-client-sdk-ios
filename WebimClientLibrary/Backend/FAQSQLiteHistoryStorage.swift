//
//  FAQSQLiteHistoryStorage.swift
//  WebimClientLibrary
//
//  Created by Nikita Kaberov on 2.08.19.
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

import Foundation
import SQLite

/**
 Class that is responsible for history storage inside SQLite DB. Uses SQLite.swift library.
 - seealso:
 https://github.com/stephencelis/SQLite.swift
 - author:
 Nikita Kaberov
 - copyright:
 2019 Webim
 */
final class FAQSQLiteHistoryStorage {
    
    // MARK: - Constants
    
    // MARK: SQLite tables and columns names
    private enum TableName: String {
        case categories = "categories"
    }
    private enum ColumnName: String {
        // In DB columns order.
        case id = "id"
        case data = "data"
    }
    
    // MARK: SQLite.swift abstractions
    
    private static let categories = Table(TableName.categories.rawValue)
    
    // In DB columns order.
    private static let id = Expression<String>(ColumnName.id.rawValue)
    private static let data = Expression<Blob?>(ColumnName.data.rawValue)
    
    
    // MARK: - Properties
    private static let queryQueue = DispatchQueue(label: "FAQSQLiteHistoryStorageQueryQueue", qos: .background)
    private let completionHandlerQueue: DispatchQueue
    private var db: Connection?
    
    
    // MARK: - Initialization
    init(dbName: String,
         queue: DispatchQueue) {
        self.completionHandlerQueue = queue
        
        createTableWith(name: dbName)
    }
    
    // MARK: - Methods
    
    // MARK: HistoryStorage protocol methods
    
    func getMajorVersion() -> Int {
        // No need in this implementation.
        return 2
    }
    
    func updateDB() {
        dropTables()
        createTables()
    }
    
    func insert(categoryId: String, categoryDictionary: [String: Any?]) {
        FAQSQLiteHistoryStorage.queryQueue.sync { [weak self] in
            guard self != nil else {
                return
            }
            do {
                try db?.run(FAQSQLiteHistoryStorage
                    .categories
                    .insert(FAQSQLiteHistoryStorage.id <- categoryId,
                            FAQSQLiteHistoryStorage.data <- FAQSQLiteHistoryStorage.convertToBlob(dictionary: categoryDictionary)))
            } catch {
                do {
                    try db!.run(FAQSQLiteHistoryStorage
                        .categories
                        .where(FAQSQLiteHistoryStorage.id == categoryId)
                        .update(FAQSQLiteHistoryStorage.data <- FAQSQLiteHistoryStorage.convertToBlob(dictionary: categoryDictionary)))
                } catch {
                    
                }
            }
        }
    }
    
    func get(categoryId: String,
             completion: @escaping ([String: Any?]?) -> ()) {
        FAQSQLiteHistoryStorage.queryQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            let query = FAQSQLiteHistoryStorage
                .categories
                .filter(FAQSQLiteHistoryStorage.id == categoryId)
                .limit(1)
            do {
                
                for row in try self.db!.prepare(query) {
                    var data: [String: Any?]?
                    if let dataValue = row[FAQSQLiteHistoryStorage.data] {
                        data = NSKeyedUnarchiver.unarchiveObject(with: Data.fromDatatypeValue(dataValue)) as? [String: Any?]
                        self.completionHandlerQueue.async {
                            completion(data)
                        }
                    }
                }
            } catch {
            }
        }
    }
    
    // MARK: Private methods
    
    private static func convertToBlob(dictionary: [String: Any?]?) -> Blob? {
        if let dictionary = dictionary {
            let data = NSKeyedArchiver.archivedData(withRootObject: dictionary)
            
            return data.datatypeValue
        }
        
        return nil
    }
    
    private func dropTables() {
        try! self.db?.run(FAQSQLiteHistoryStorage.categories.drop(ifExists: true))
    }
    
    private func createTableWith(name: String) {
        FAQSQLiteHistoryStorage.queryQueue.sync { [weak self] in
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
            self.db?.userVersion = 2
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
         CREATE TABLE categories
         id TEXT PRIMARY KEY NOT NULL,
         data TEXT
         */
        try! self.db?.run(FAQSQLiteHistoryStorage.categories.create(ifNotExists: true) { t in
            t.column(FAQSQLiteHistoryStorage.id, primaryKey: true)
            t.column(FAQSQLiteHistoryStorage.data)
        })
    }
    
}
