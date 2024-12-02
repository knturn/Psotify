//
//  RequestFactory.swift
//  Psotify
//
//  Created by Turan, Kaan on 30.11.2024.
//

import Foundation

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

class PsotifyRequestFactory {
    static func createRequest(for endpoint: PsotifyEndpoint) -> URLRequest? {
        let builder: RequestBuilder

        switch endpoint {
        case .authCode:
            guard let url = Configuration.authBaseURL?.appendingPathComponent("authorize") else { return nil }
            builder = RequestBuilder(url: url, httpMethod: .GET)
                .setQueryParameters(constructParams(for: endpoint))
                .setHeaders([EndPointConstants.contentType: EndPointConstants.urlEncoded])

        case .token(let code):
            guard let url = Configuration.authBaseURL?.appendingPathComponent("api/token") else { return nil }
            builder = RequestBuilder(url: url, httpMethod: .POST)
                .setBody([
                    EndPointConstants.grantType: EndPointConstants.authorizationCode,
                    "code": code,
                    EndPointConstants.redirectURI: Configuration.redirectURI
                ])
                .setHeaders([
                    EndPointConstants.contentType: EndPointConstants.urlEncoded,
                    EndPointConstants.authorization: Configuration.authorization
                ])

        case .refreshToken(let refreshToken):
            guard let url = Configuration.authBaseURL?.appendingPathComponent("api/token") else { return nil }
            builder = RequestBuilder(url: url, httpMethod: .POST)
                .setBody([
                    EndPointConstants.grantType: EndPointConstants.refreshToken,
                    EndPointConstants.refreshToken: refreshToken
                ])
                .setHeaders([
                    EndPointConstants.contentType: EndPointConstants.urlEncoded,
                    EndPointConstants.authorization: Configuration.authorization
                ])

        case .newReleases:
            guard let url = Configuration.apiBaseURL?.appendingPathComponent("browse/new-releases") else { return nil }
            builder = RequestBuilder(url: url, httpMethod: .GET)
                .setQueryParameters(constructParams(for: endpoint))
                .setHeaders([EndPointConstants.authorization: getBearerHeader()])

        case .album(let id):
            guard let url = Configuration.apiBaseURL?.appendingPathComponent("albums/\(id)") else { return nil }
            builder = RequestBuilder(url: url, httpMethod: .GET)
                .setHeaders([EndPointConstants.authorization: getBearerHeader()])

        case .userProfile:
            guard let url = Configuration.apiBaseURL?.appendingPathComponent("me") else { return nil }
            builder = RequestBuilder(url: url, httpMethod: .GET)
                .setHeaders([EndPointConstants.authorization: getBearerHeader()])

        case .playlist(let id):
            guard let url = Configuration.apiBaseURL?.appendingPathComponent("playlists/\(id)") else { return nil }
            builder = RequestBuilder(url: url, httpMethod: .GET)
                .setHeaders([EndPointConstants.authorization: getBearerHeader()])

        case .userPlaylists:
            guard let url = Configuration.apiBaseURL?.appendingPathComponent("me/playlists") else { return nil }
            builder = RequestBuilder(url: url, httpMethod: .GET)
                .setHeaders([EndPointConstants.authorization: getBearerHeader()])
        case .track(id: let id):
          guard let url = Configuration.apiBaseURL?.appendingPathComponent("tracks/\(id)") else { return nil }
          builder = RequestBuilder(url: url, httpMethod: .GET)
              .setHeaders([EndPointConstants.authorization: getBearerHeader()])
        case .search(query: let query):
            guard let url = Configuration.apiBaseURL?.appendingPathComponent("search") else { return nil }
            builder = RequestBuilder(url: url, httpMethod: .GET)
                .setHeaders([EndPointConstants.authorization: getBearerHeader()])
                .setQueryParameters(constructParams(for: endpoint))
        }

        return builder.build()
    }

    private static func constructParams(for endpoint: PsotifyEndpoint) -> [URLQueryItem] {
        switch endpoint {
        case .authCode:
            return [
                URLQueryItem(name: EndPointConstants.responseType, value: "code"),
                URLQueryItem(name: EndPointConstants.clientID, value: Configuration.clientID),
                URLQueryItem(name: EndPointConstants.scope, value: EndPointConstants.scopeValue),
                URLQueryItem(name: EndPointConstants.redirectURI, value: Configuration.redirectURI),
                URLQueryItem(name: EndPointConstants.state, value: EndPointConstants.authState),
                URLQueryItem(name: EndPointConstants.showDialog, value: "TRUE")
            ]
        case .newReleases(let limit):
            return [
                URLQueryItem(name: "limit", value: limit)
            ]
        case .search(let query, let types):
            let typesString = types.joined(separator: ",")
            return [
                  URLQueryItem(name: "q", value: query),
                  URLQueryItem(name: "type", value: typesString)
            ]
        default:
            return []
        }
    }

    private static func getBearerHeader() -> String {
        let accessToken = UserDefaultsService.getElement(forKey: UserDefaultsServiceKeys.tokenStorage.rawValue, type: PsotifyTokenStorageModel.self)?.accessToken
        return "Bearer " + (accessToken ?? "")
    }
}
