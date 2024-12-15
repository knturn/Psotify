//
//  AlbumDetailViewModel.swift
//  Psotify
//
//  Created by Turan, Kaan on 28.11.2024.
//

import SwiftUI

class AlbumDetailViewModel: ObservableObject {
  @Published var screenState: ScreenState = .isLoading
  @Published var songList: AlbumItem?

  private let getAlbumUseCase: GetAlbumsUseCaseProtocol
  private let id: String

  init(getAlbumUseCase: GetAlbumsUseCaseProtocol = AppDIContainer.shared.resolve(GetAlbumsUseCaseProtocol.self), id: String) {
    self.id = id
    self.getAlbumUseCase = getAlbumUseCase
  }

  @MainActor
  func fetchSongList() {
      Task { [weak self] in
        guard let self else { return }
          self.screenState = .isLoading
          do {
              let songList = try await getAlbumUseCase.fetchOneAlbum(with: self.id)
              self.songList = songList
              self.screenState = .loaded
          } catch {
              self.screenState = .error("Çalma listeleri alınırken hata oluştu.")
          }
      }
  }
}

//MARK: For navigation process
extension AlbumDetailViewModel: Equatable, Hashable {
  static func == (lhs: AlbumDetailViewModel, rhs: AlbumDetailViewModel) -> Bool {
    lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
         hasher.combine(id)
     }
}
