//
//  Psotify+Endpoints.swift
//  Psotify
//
//  Created by Turan, Kaan on 15.11.2024.
//

import Foundation
enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

protocol ServiceEndpointsProtocol {
    var endpointURL: URL? { get }
    var requestBody: [String: Any]? { get }
    var request: URLRequest? { get }
}

enum PsotifyEndpoint: ServiceEndpointsProtocol {
    case token(code: String)
    case refreshToken(refreshToken: String)
    case authCode

    private enum EndPointConstants {
        static let grantType = "grant_type"
        static let authorizationCode = "authorization_code"
        static let refreshToken = "refresh_token"
        static let redirectURI = "redirect_uri"
        static let contentType = "Content-Type"
        static let authorization = "Authorization"
        static let urlEncoded = "application/x-www-form-urlencoded"
        static let responseType = "response_type"
        static let clientID = "client_id"
        static let scope = "scope"
        static let state = "state"
        static let showDialog = "show_dialog"
    }

    var endpointURL: URL? {
        switch self {
        case .authCode:
            guard let authBaseString = Constants.authBaseURL,
                  let url = URL(string: authBaseString) else { return nil }
            return url.appendingPathComponent("authorize")
        case .token, .refreshToken:
            guard let authBaseString = Constants.authBaseURL,
                  let url = URL(string: authBaseString) else { return nil }
            return url.appendingPathComponent("api/token")
        }
    }
    
    var params: [URLQueryItem] {
        switch self {
        case .authCode:
            return [
                URLQueryItem(name: EndPointConstants.responseType, value: "code"),
                URLQueryItem(name: EndPointConstants.clientID, value: Constants.clientID),
                URLQueryItem(name: EndPointConstants.scope, value: Constants.scope),
                URLQueryItem(name: EndPointConstants.redirectURI, value: Constants.redirectURI),
                URLQueryItem(name: EndPointConstants.state, value: Constants.authState),
                URLQueryItem(name: EndPointConstants.showDialog, value: "TRUE")
            ]
        default:
            return []
        }
    }
    
    var requestBody: [String: Any]? {
        switch self {
        case .token(let code):
            return [
                EndPointConstants.grantType: EndPointConstants.authorizationCode,
                "code": code,
                EndPointConstants.redirectURI: Constants.redirectURI ?? ""
            ]
        case .refreshToken(let refreshToken):
            return [
                EndPointConstants.grantType: EndPointConstants.refreshToken,
                EndPointConstants.refreshToken: refreshToken
            ]
        default:
            return nil
        }
    }
    
    var request: URLRequest? {
        guard let url = endpointURL else { return nil }
        
        var request = URLRequest(url: urlWithParams(url))
        request.httpMethod = httpMethod.rawValue
        addRequestBody(&request)
        addRequestHeaders(&request)
        
        return request
    }
    
    private var httpMethod: HTTPMethod {
        switch self {
        case .authCode: return .GET
        case .token, .refreshToken: return .POST
        }
    }
}

// MARK: - Helper Functions
private extension PsotifyEndpoint {
    func createAuthorizationHeader() -> String {
        let credentials = "\(String(describing: Constants.clientID)):\(String(describing: Constants.clientSecret))"
        guard let data = credentials.data(using: .utf8) else {
            fatalError("Failed to encode client credentials.")
        }
        return "Basic \(data.base64EncodedString())"
    }
    
    func urlWithParams(_ url: URL) -> URL {
        guard !params.isEmpty else { return url }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = params
        return components?.url ?? url
    }
    
    func addRequestBody(_ request: inout URLRequest) {
        guard let bodyParams = requestBody else { return }
        let bodyString = bodyParams.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)
    }
    
    func addRequestHeaders(_ request: inout URLRequest) {
        switch self {
        case .token, .refreshToken:
            request.setValue(EndPointConstants.urlEncoded, forHTTPHeaderField: EndPointConstants.contentType)
            request.setValue(createAuthorizationHeader(), forHTTPHeaderField: EndPointConstants.authorization)
        case .authCode:
            break
        }
    }
}
