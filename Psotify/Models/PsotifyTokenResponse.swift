//
//  PsotifyTokenResponse.swift
//  Psotify
//
//  Created by Turan, Kaan on 15.11.2024.
//

import Foundation
struct PsotifyTokenResponse: Codable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let refreshToken: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
    }
}

struct PsotifyTokenStorageModel: Codable {
    let accessToken: String
    let expireDate: Date
    let refreshToken: String?
    
    init(response: PsotifyTokenResponse) {
        self.accessToken = response.accessToken
        self.expireDate = Date().addingTimeInterval(TimeInterval(response.expiresIn))
        self.refreshToken = response.refreshToken
    }
}
