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

protocol NetworkManagerProtocol: CompletionHandlerSettable {
    init(urlSession: URLSession)
    
    func fetch(_ requestKind: RequestKind)
    
    @available(iOS 13.0, *)
    func fetch(_ requestKind: RequestKind) async throws -> Any
}

class NetworkManager: NetworkManagerProtocol {
    private var urlSession: URLSession
    private weak var demoVisitorCompletion: (any WMVisitorFieldsParserCompletionHandler)?
    
    required init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func fetch(_ requestKind: RequestKind) {
        var urlComponents: URLComponents
        switch requestKind {
        case .demoVisitor(let value):
            urlComponents = .components(for: .demoVisitor(value))
        }
        
        let request = URLRequest(components: urlComponents)
        
        switch requestKind {
        case .demoVisitor(let value):
            demoVisitorRequest(request: request, value: value)
        }
    }
    
    @available(iOS 13.0, *)
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
    
    private func demoVisitorRequest(request: URLRequest, value: Int) {
        urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            if let _ = error {
                self.demoVisitorCompletion?.onFailure(error: .unknown)
                return
            }
            
            guard let data = data else {
                self.demoVisitorCompletion?.onFailure(error: .unknown)
                return
            }
            
            if let visitorFieldsError = data.toVisitorFieldsError {
                self.demoVisitorCompletion?.onFailure(error: visitorFieldsError)
            } else {
                self.demoVisitorCompletion?.onSuccess(value: DemoVisitorOutput(data, DemoVisitor(rawValue: value)))
            }
            
        }.resume()
    }
    
    @available(iOS 13.0, *)
    private func demoVisitorAsyncRequest(request: URLRequest, value: Int) async throws -> Any {
        return try await withCheckedThrowingContinuation { continuation in
            urlSession.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let data = data else {
                    continuation.resume(throwing: WMVisitorFieldsError.notFound)
                    return
                }
                
                if let visitorFieldsError = data.toVisitorFieldsError {
                    continuation.resume(throwing: visitorFieldsError)
                } else {
                    continuation.resume(returning: DemoVisitorOutput(data, DemoVisitor(rawValue: value)))
                }
                
            }.resume()
        }
    }
}

// MARK: Conform to CompletionHandlerSettable
extension NetworkManager: CompletionHandlerSettable {
    func set(completion: (any WMVisitorFieldsParserCompletionHandler)?) {
        self.demoVisitorCompletion = completion
    }
}
