//
//  HomeViewModel.swift
//  Psotify
//
//  Created by Turan, Kaan on 21.11.2024.
//

import SwiftUI

class HomeViewModel: ObservableObject {
  private let getUserProfileUseCase: GetUserProfileUseCaseProtocol
  private let getAlbumsUseCase: GetAlbumsUseCaseProtocol
  private let getPlaylistUseCase: GetPlaylistsUseCaseProtocol

  @Published var newReleases: [AlbumItem]?
  @Published var userModel: SpotifyUserProfile?
  @Published var featuredPlayList: [PlaylistItem]?
  @Published var playlistModels: [String: PlayListDetailResponse] = [:]
  @Published var screenState: ScreenState = .isLoading

  init(getUserProfileUseCase: GetUserProfileUseCaseProtocol = AppDIContainer.shared.resolve(GetUserProfileUseCaseProtocol.self),
       getAlbumsUseCase: GetAlbumsUseCaseProtocol = AppDIContainer.shared.resolve(GetAlbumsUseCaseProtocol.self),
       getPlaylistUseCase: GetPlaylistsUseCaseProtocol = AppDIContainer.shared.resolve(GetPlaylistsUseCaseProtocol.self)) {
    self.getUserProfileUseCase = getUserProfileUseCase
    self.getAlbumsUseCase = getAlbumsUseCase
    self.getPlaylistUseCase = getPlaylistUseCase
  }

  func fetchUserProfile() async {
    do {
      let userModel = try await getUserProfileUseCase.fetchUserInfo()
      DispatchQueue.main.async { [weak self] in
        self?.userModel = userModel
        self?.updateScreenState()
      }
    } catch {
      DispatchQueue.main.async { [weak self] in
        self?.screenState = .error("Kullanıcı bilgileri alınırken hata oluştu.")
      }
    }
  }

  func fetchNewReleases() async {
    do {
      let albums = try await getAlbumsUseCase.fetchNewReleases(limit: 6)
      DispatchQueue.main.async { [weak self] in
        self?.newReleases = albums.items
        self?.updateScreenState()
      }
    } catch {
      DispatchQueue.main.async { [weak self] in
        self?.screenState = .error("Yeni albümler alınırken hata oluştu.")
      }
    }
  }

  func fetchUserPlaylists() async {
    do {
      let featuredPlayList = try await getPlaylistUseCase.fetchUserPlaylist()
      DispatchQueue.main.async { [weak self] in
        self?.featuredPlayList = featuredPlayList
        self?.updateScreenState()
      }
    } catch {
      DispatchQueue.main.async { [weak self] in
        self?.screenState = .error("Çalma listeleri alınırken hata oluştu.")
      }
    }
  }

  func fetchPlaylist(for id: String) async {
    do {
      let playlist = try await getPlaylistUseCase.fetchPlaylist(with: id)
      DispatchQueue.main.async { [weak self] in
        self?.playlistModels[id] = playlist
      }
    } catch {
      DispatchQueue.main.async { [weak self] in
        self?.screenState = .error("Çalma listeleri alınırken hata oluştu.")
      }
    }
  }


  func createHorizontalScrollUIModel(_ id: String) -> HorizontalScrollViewUIModel? {
    guard let model = self.playlistModels[id] else { return nil }
    let uiModel = HorizontalScrollViewUIModel(response: model)
    return uiModel
  }

  private func updateScreenState() {
    if newReleases != nil, userModel != nil, featuredPlayList != nil {
      screenState = .loaded
    }
  }
}
