//
//  AlbumDetailViewModel.swift
//  Psotify
//
//  Created by Turan, Kaan on 28.11.2024.
//

import SwiftUI

class AlbumDetailViewModel: ObservableObject {
  private let getAlbumUseCase: GetAlbumsUseCaseProtocol
  let getSongUseCaseProtocol: GetSongUseCaseProtocol
  private let id: String
  @Published var screenState: ScreenState = .isLoading
  @Published var songList: AlbumItem?

  init(getAlbumUseCase: GetAlbumsUseCaseProtocol, getSongUseCaseProtocol: GetSongUseCaseProtocol, id: String) {
    self.id = id
    self.getAlbumUseCase = getAlbumUseCase
    self.getSongUseCaseProtocol = getSongUseCaseProtocol
  }


  func fetchSongList() async {
    DispatchQueue.main.async { [weak self] in
      self?.screenState = .isLoading
    }
    do {
      let songList = try await getAlbumUseCase.fetchOneAlbum(with: self.id)
      DispatchQueue.main.async { [weak self] in
        self?.songList = songList
        self?.screenState = .loaded
      }
    } catch {
      DispatchQueue.main.async { [weak self] in
        self?.screenState = .error("Çalma listeleri alınırken hata oluştu.")
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
