//
//  HorizontalScrollViewUIModel.swift
//  Psotify
//
//  Created by Turan, Kaan on 27.11.2024.
//

import Foundation
struct HorizontalScrollViewUIModel {
  let title: String
  let description: String
  let tracks: [PlayListTrackItem]?
  let imageURL: URL?
  let songUseCase: GetSongUseCaseProtocol

  init(response: PlayListDetailResponse, songUseCase: GetSongUseCaseProtocol = AppDIContainer.shared.resolve(GetSongUseCaseProtocol.self)) {
    self.title = response.name
    self.description = response.description
    self.tracks = response.tracks.items
    self.imageURL = response.images?.first?.imageURL
    self.songUseCase = songUseCase
  }
}
