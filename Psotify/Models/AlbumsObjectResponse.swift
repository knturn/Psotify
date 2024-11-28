//
//  AlbumsObjectResponse.swift
//  Psotify
//
//  Created by Turan, Kaan on 26.11.2024.
//

import Foundation

// MARK: - Root Model
struct AlbumsObjectResponse: Codable {
    let albums: Albums
}

struct Albums: Codable {
    let href: String
    let limit: Int
    let next: String?
    let offset: Int
    let previous: String?
    let total: Int
    let items: [AlbumItem]
}
