//
//  SubModels.swift
//  Psotify
//
//  Created by Turan, Kaan on 28.11.2024.
//

import Foundation

struct Tracks: Codable {
    let href: String?
    let limit: Int?
    let next: String?
    let offset: Int?
    let previous: String?
    let total: Int?
    let items: [TrackItem]?
}

struct TrackItem: Codable {
    let album: AlbumItem?
    let artists: [Artist]?
    let availableMarkets: [String]?
    let discNumber: Int?
    let durationMS: Int?
    let explicit: Bool?
    let externalUrls: ExternalURLs
    let href: String?
    let id: String
    let isPlayable: Bool?
    let linkedFrom: LinkedFrom?
    let restrictions: AlbumRestrictions?
    let name: String?
    let previewURL: String?
    let trackNumber: Int?
    let type: String?
    let uri: String?
    let isLocal: Bool?

    enum CodingKeys: String, CodingKey {
        case album, artists, name, href, id, type, uri
        case availableMarkets = "available_markets"
        case discNumber = "disc_number"
        case durationMS = "duration_ms"
        case explicit
        case externalUrls = "external_urls"
        case isPlayable = "is_playable"
        case linkedFrom = "linked_from"
        case previewURL = "preview_url"
        case trackNumber = "track_number"
        case isLocal = "is_local"
        case restrictions
    }
}

struct LinkedFrom: Codable {
    let externalUrls: ExternalURLs
    let href: String
    let id: String
    let type: String
    let uri: String

    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case href, id, type, uri
    }
}

struct Copyright: Codable {
    let text: String
    let type: String
}

struct ExternalIDs: Codable {
    let isrc: String?
    let ean: String?
    let upc: String?
}

//MARK: USER PlayLists SubModels
struct PlaylistItem: Codable {
    let collaborative: Bool
    let description: String
    let externalUrls: ExternalURLs
    let href: String
    let id: String
    let images: [SpotifyImage]
    let name: String
    let isPublic: Bool
    let snapshotID: String
    let tracks: PlaylistTracks
    let type: String
    let uri: String
    let primaryColor: String?

    enum CodingKeys: String, CodingKey {
        case collaborative, description, href, id, images, name, type, uri
        case externalUrls = "external_urls"
        case isPublic = "public"
        case snapshotID = "snapshot_id"
        case tracks, primaryColor = "primary_color"
    }
}

struct PlaylistTracks: Codable {
    let href: String
    let total: Int
}
