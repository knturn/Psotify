//
//  AlbumItem.swift
//  Psotify
//
//  Created by Turan, Kaan on 27.11.2024.
//

import Foundation

struct AlbumItem: Codable, Identifiable {
    let albumType: String
    let totalTracks: Int
    let availableMarkets: [String]
    let externalUrls: ExternalURLs
    let href: String
    let id: String
    let images: [SpotifyImage]
    let name: String
    let releaseDate: String
    let releaseDatePrecision: String
    let restrictions: AlbumRestrictions?
    let type: String
    let uri: String
    let artists: [Artist]
    let tracks: Tracks?
    let copyrights: [Copyright]?
    let externalIds: ExternalIDs?
    let genres: [String]?
    let label: String?
    let popularity: Int?

    enum CodingKeys: String, CodingKey {
        case albumType = "album_type"
        case totalTracks = "total_tracks"
        case availableMarkets = "available_markets"
        case externalUrls = "external_urls"
        case href, id, images, name
        case releaseDate = "release_date"
        case releaseDatePrecision = "release_date_precision"
        case restrictions, type, uri, artists, tracks, copyrights
        case externalIds = "external_ids"
        case genres, label, popularity
    }
}

struct ExternalURLs: Codable, Hashable {
    let spotify: String
}

struct SpotifyImage: Codable, Hashable  {
    let url: String
    let height: Int?
    let width: Int?

  var imageURL: URL? {
    return URL(string: url)
  }
}

struct AlbumRestrictions: Codable {
    let reason: String
}

struct Artist: Codable {
    let externalUrls: ExternalURLs
    let href: String
    let id: String
    let name: String
    let type: String
    let uri: String

    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case href, id, name, type, uri
    }
}

