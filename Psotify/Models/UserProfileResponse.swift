//
//  UserProfileResponse.swift
//  Psotify
//
//  Created by Turan, Kaan on 26.11.2024.
//

import Foundation

struct SpotifyUserProfile: Codable, Equatable, Hashable {
    let country: String
    let displayName: String
    let email: String
    let explicitContent: ExplicitContent?
    let externalUrls: ExternalURLs?
    let followers: Followers?
    let href: String
    let id: String
    let images: [SpotifyImage]
    let product: String
    let type: String
    let uri: String

    enum CodingKeys: String, CodingKey {
        case country
        case displayName = "display_name"
        case email
        case explicitContent = "explicit_content"
        case externalUrls = "external_urls"
        case followers
        case href
        case id
        case images
        case product
        case type
        case uri
    }
}

struct ExplicitContent: Codable, Hashable {
    let filterEnabled: Bool
    let filterLocked: Bool

    enum CodingKeys: String, CodingKey {
        case filterEnabled = "filter_enabled"
        case filterLocked = "filter_locked"
    }
}

struct Followers: Codable, Hashable {
    let href: String?
    let total: Int
}
