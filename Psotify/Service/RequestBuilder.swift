//
//  RequestBuilder.swift
//  Psotify
//
//  Created by Turan, Kaan on 30.11.2024.
//

import Foundation

class RequestBuilder {
    private var url: URL
    private var httpMethod: HTTPMethod
    private var body: [String: Any]?
    private var headers: [String: String?]

    init(url: URL, httpMethod: HTTPMethod) {
        self.url = url
        self.httpMethod = httpMethod
        self.headers = [:]
    }

    func setBody(_ body: [String: Any]?) -> RequestBuilder {
        self.body = body
        return self
    }

    func setHeaders(_ headers: [String: String?]) -> RequestBuilder {
        self.headers = headers
        return self
    }

    func setQueryParameters(_ parameters: [URLQueryItem]) -> RequestBuilder {
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = parameters
        if let updatedURL = urlComponents?.url {
            self.url = updatedURL
        }
        return self
    }

    func build() -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        if let body = body {
            let bodyString = body.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            request.httpBody = bodyString.data(using: .utf8)
        }
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        return request
    }
}
