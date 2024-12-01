//
//  SectionGridViewUIModel.swift
//  Psotify
//
//  Created by Turan, Kaan on 29.11.2024.
//

import Foundation

struct SectionGridViewUIModel {
  let title: String
  let gridItems: [AlbumItem]?
  let albumsUseCase: GetAlbumsUseCaseProtocol
  let songUseCase: GetSongUseCaseProtocol

  init(title: String, gridItems: [AlbumItem]?, albumsUseCase: GetAlbumsUseCaseProtocol, songUseCase: GetSongUseCaseProtocol) {
    self.title = title
    self.gridItems = gridItems
    self.albumsUseCase = albumsUseCase
    self.songUseCase = songUseCase
  }

  func getAlbumDetailViewModel(with id: String) -> AlbumDetailViewModel {
    AlbumDetailViewModel(getAlbumUseCase: albumsUseCase, getSongUseCaseProtocol: songUseCase, id: id)
  }
}
