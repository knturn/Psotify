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
    case newReleases(accessToken: String, limit: String)
    case userProfile(accessToken: String)
//  Deprecated
//  case featuredPlaylist(accessToken: String)
    case userPlaylists(accessToken: String)
    case playlist(accessToken: String, id: String)
    case album(accessToken: String, id: String)

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
        static let scopeValue = "user-read-private user-read-email"
        static let authState = "TRUE"
        static let state = "state"
        static let showDialog = "show_dialog"
    }

    var endpointURL: URL? {
        switch self {
        case .authCode:
            return Configuration.authBaseURL?.appendingPathComponent("authorize")
        case .token, .refreshToken:
            return Configuration.authBaseURL?.appendingPathComponent("api/token")
        case .newReleases:
          return Configuration.apiBaseURL?.appendingPathComponent("browse/new-releases")
        case .album(_, let id):
          return Configuration.apiBaseURL?.appendingPathComponent("albums/\(id)")
        case .userProfile:
          return Configuration.apiBaseURL?.appendingPathComponent("me")
//        case .featuredPlaylist:
//          return Configuration.apiBaseURL?.appendingPathComponent("browse/featured-playlists")
        case .playlist(_, let id):
          return Configuration.apiBaseURL?.appendingPathComponent("playlists/\(id)")
        case .userPlaylists:
          return Configuration.apiBaseURL?.appendingPathComponent("me/playlists")
        }
    }
    
    var params: [URLQueryItem] {
        switch self {
        case .authCode:
            return [
                URLQueryItem(name: EndPointConstants.responseType, value: "code"),
                URLQueryItem(name: EndPointConstants.clientID, value: Configuration.clientID),
                URLQueryItem(name: EndPointConstants.scope, value: EndPointConstants.scopeValue),
                URLQueryItem(name: EndPointConstants.redirectURI, value: Configuration.redirectURI),
                URLQueryItem(name: EndPointConstants.state, value: EndPointConstants.authState),
                URLQueryItem(name: EndPointConstants.showDialog, value: "TRUE")
            ]
        case .newReleases(_, let limit):
          return [
            URLQueryItem(name: "limit", value: limit)
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
                EndPointConstants.redirectURI: Configuration.redirectURI
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
        case .authCode, .newReleases, .userProfile, .playlist, .userPlaylists, .album: return .GET
        case .token, .refreshToken: return .POST
        }
    }
}

// MARK: - Helper Functions
private extension PsotifyEndpoint {
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
            request.setValue(Configuration.authorization, forHTTPHeaderField: EndPointConstants.authorization)
        case .authCode:
            break
        case .newReleases(let accessToken, _), .album(let accessToken, _), .userProfile(let accessToken), .playlist(let accessToken, _), .userPlaylists(let accessToken):
          request.setValue("Bearer " + accessToken, forHTTPHeaderField: EndPointConstants.authorization )
        }
    }
}
