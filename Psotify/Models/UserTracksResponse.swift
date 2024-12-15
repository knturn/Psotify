//
//  UserTracksResponse.swift
//  Psotify
//
//  Created by Turan, Kaan on 4.12.2024.
//

import Foundation

struct UserTracksResponse: Codable {
    let href: String
    let items: [UserTrackItem]
}

struct UserTrackItem: Codable {
    let addedAt: String
    let track: UserTrack

    enum CodingKeys: String, CodingKey {
        case addedAt = "added_at"
        case track
    }
}

struct UserTrack: Codable {
    let album: AlbumItem
    let name: String
    let popularity: Int
    let type: String
    let uri: String
}
