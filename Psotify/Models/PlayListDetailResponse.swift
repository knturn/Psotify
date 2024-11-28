//
//  PlayListDetailResponse.swift
//  Psotify
//
//  Created by Turan, Kaan on 27.11.2024.
//

import Foundation

struct PlayListDetailResponse: Codable {
    let description: String
    let id: String
    let images: [SpotifyImage]?
    let name: String
    let tracks: PlayListTracks

    enum CodingKeys: String, CodingKey {
        case description
        case id, images, name
        case tracks
    }
}

struct PlayListTracks: Codable {
    let total: Int?
    let items: [PlayListTrackItem]?
}

struct PlayListTrackItem: Codable, Identifiable {
    var id: String { track?.id ?? UUID().uuidString }
    let track: PlayListTrack?
}

struct PlayListTrack: Codable {
    let id, name: String?
}

