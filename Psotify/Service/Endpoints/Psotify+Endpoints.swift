//
//  Psotify+Endpoints.swift
//  Psotify
//
//  Created by Turan, Kaan on 15.11.2024.
//

import Foundation

enum PsotifyEndpoint {
    case token(code: String)
    case refreshToken(refreshToken: String)
    case authCode
    case newReleases(limit: String)
    case userProfile
    case userPlaylists
    case playlist(id: String)
    case album(id: String)

    var request: URLRequest? {
        return PsotifyRequestFactory.createRequest(for: self)
    }
}
