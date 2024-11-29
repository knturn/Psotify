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
  let useCase: GetAlbumsUseCaseProtocol

  init(title: String, gridItems: [AlbumItem]?, useCase: GetAlbumsUseCaseProtocol) {
    self.title = title
    self.gridItems = gridItems
    self.useCase = useCase
  }

  func getAlbumDetailViewModel(with id: String) -> AlbumDetailViewModel {
    AlbumDetailViewModel(getAlbumUseCase: useCase, id: id)
  }
}
