//
//  NetworkManager.swift
//  WebimClientLibrary_Example
//
//  Created by Аслан Кутумбаев on 17.05.2023.
//  Copyright © 2023 Webim. All rights reserved.
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

enum RequestKind {
    case demoVisitor(Int)
}

protocol NetworkManagerProtocol {
    init(urlSession: URLSession)
    
    func fetch(_ requestKind: RequestKind) async throws -> Any
}

class NetworkManager: NetworkManagerProtocol {
    private var urlSession: URLSession
    
    required init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func fetch(_ requestKind: RequestKind) async throws -> Any {
        var urlComponents: URLComponents
        switch requestKind {
        case .demoVisitor(let value):
            urlComponents = .components(for: .demoVisitor(value))
        }
        
        let request = URLRequest(components: urlComponents)
        
        switch requestKind {
        case .demoVisitor(let value):
            return try await demoVisitorAsyncRequest(request: request, value: value)
        }
    }
    
    private func demoVisitorAsyncRequest(request: URLRequest, value: Int) async throws -> Any {
        return try await withCheckedThrowingContinuation { continuation in
            urlSession.dataTask(with: request) { data, _, error in

                if error != nil {
                    continuation.resume(returning: DemoVisitorOutput(nil, DemoVisitor(rawValue: value)))
                    return
                }
                
                guard let data = data else {
                    continuation.resume(returning: DemoVisitorOutput(nil, DemoVisitor(rawValue: value)))
                    return
                }
                
                if data.toVisitorFieldsError != nil {
                    continuation.resume(returning: DemoVisitorOutput(nil, DemoVisitor(rawValue: value)))
                } else {
                    continuation.resume(returning: DemoVisitorOutput(data, DemoVisitor(rawValue: value)))
                }
                
            }.resume()
        }
    }
}
