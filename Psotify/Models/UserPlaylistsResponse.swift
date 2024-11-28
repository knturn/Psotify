//
//  UserPlaylistsResponse.swift
//  Psotify
//
//  Created by Turan, Kaan on 27.11.2024.
//

import Foundation

struct UserPlaylistsResponse: Codable {
    let href: String
    let limit: Int
    let next: String?
    let offset: Int
    let previous: String?
    let total: Int
    let items: [PlaylistItem]
}
