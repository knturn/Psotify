//
//  SearchResponse.swift
//  Psotify
//
//  Created by Turan, Kaan on 2.12.2024.
//

import Foundation

struct SearchResponse: Codable {
    let tracks: Tracks?
    let albums: Albums?
}
