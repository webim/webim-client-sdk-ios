//
//  WebimPingManager.swift
//  WebimMobileSDK
//
//  Created by Anna Frolova on 07.02.2025.
//  Copyright © 2025 Webim. All rights reserved.
//

import UIKit

class WebimPingManager {

    private var baseURL: String
    private let session: URLSession = .shared

    init(serverURL: String) {
        self.baseURL = serverURL
    }

    func sendPing(completion: @escaping (Error?) -> Void) {
        guard let url = buildPingURL() else {
            completion(PingError.invalidURL)
            return
        }

        let task = session.dataTask(with: url) { (_, response, error) in
            if let error = error {
                completion(error)
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                completion(PingError.invalidResponse(statusCode: httpResponse.statusCode))
                return
            }
            
            completion(nil)
        }

        task.resume()
    }

    private func buildPingURL() -> URL? {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "pinger-id", value: "1"),
            URLQueryItem(name: "ts", value: "1")
        ]

        return components?.url
    }

    enum PingError: Error {
        case invalidURL
        case invalidResponse(statusCode: Int)
    }
}
