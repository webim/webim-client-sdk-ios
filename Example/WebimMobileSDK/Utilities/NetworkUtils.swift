//
//  NetworkUtils.swift
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

struct InternalScheme: RawRepresentable {
    static let https = InternalScheme(rawValue: "https")
    let rawValue: String
}

struct InternalHost {
    static let defaultHost = "demo.webim.ru"
    static var currentHost: String {
        let host = Settings.shared.accountName
        if host.contains("https://") {
            return host.replacingOccurrences(of: "https://", with: "")
        } else {
            return Settings.shared.accountName + ".webim.ru"
        }
    }
}

enum InternalPath: String {
    case demoVisitor = "/l/v/m/demo-visitor"
}

enum InternalQueryKeys: String {
    case demoVisitor = "webim-visitor"
}

enum InternalURLKind {
    case demoVisitor(Int)
}

extension URLRequest {
    init(components: URLComponents) {
        guard let url = components.url else {
            preconditionFailure()
        }
        self.init(url: url)
    }
}

extension Data {
    
    var toVisitorFieldsError: WMVisitorFieldsError? {
        let dictionary = try? JSONSerialization.jsonObject(with: self) as? [String: String]
        
        return dictionary?
            .filter { $0.key == "error" }
            .first
            .flatMap {
                switch $0.value {
                case WMVisitorFieldsError.notFound.rawValue:
                    return WMVisitorFieldsError.notFound
                case WMVisitorFieldsError.forbidden.rawValue:
                    return .forbidden
                default:
                    return .unknown
                }
            }
    }
}

extension URLComponents {
    init(
        scheme: InternalScheme = .https,
        host: String = InternalHost.defaultHost,
        path: String,
        queryItems: [URLQueryItem]? = nil
    ) {
        var components = URLComponents()
        components.scheme = scheme.rawValue
        components.host = host
        components.path = path
        components.queryItems = queryItems
        self = components
    }
}

extension URLComponents {
    
    static func components(for kind: InternalURLKind) -> URLComponents {
        switch kind {
        case .demoVisitor(let value):
            return componentsForDemoVisitor(demoVisitor: value)
        }
    }
    
    private static func componentsForDemoVisitor(demoVisitor: Int) -> URLComponents {
        URLComponents(
            scheme: .https,
            host: InternalHost.currentHost,
            path: InternalPath.demoVisitor.rawValue,
            queryItems: [
                URLQueryItem(name: InternalQueryKeys.demoVisitor.rawValue, value: String(demoVisitor))
            ]
        )
    }
}
