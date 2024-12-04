//
//  HomeViewModel.swift
//  Psotify
//
//  Created by Turan, Kaan on 21.11.2024.
//

import SwiftUI

final class HomeViewModel: ObservableObject {
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

    func fetch() {
        Task { [weak self] in
            guard let self else { return }
            await self.fetchUserProfile()
            await self.fetchNewReleases()
            await self.fetchUserPlaylists()
        }
    }

    private func fetchUserProfile() async {
        do {
            let userModel = try await getUserProfileUseCase.fetchUserInfo()
            updateOnMain {
                self.userModel = userModel
                self.updateScreenStateIfNeeded()
            }
        } catch {
            handleFetchError("Kullanıcı bilgileri alınırken hata oluştu.")
        }
    }

    private func fetchNewReleases() async {
        do {
            let albums = try await getAlbumsUseCase.fetchNewReleases(limit: 6)
            updateOnMain {
                self.newReleases = albums.items
                self.updateScreenStateIfNeeded()
            }
        } catch {
            handleFetchError("Yeni albümler alınırken hata oluştu.")
        }
    }

    private func fetchUserPlaylists() async {
        do {
            let playlists = try await getPlaylistUseCase.fetchUserPlaylist()
            updateOnMain {
                self.featuredPlayList = playlists
                self.updateScreenStateIfNeeded()
            }
        } catch {
            handleFetchError("Çalma listeleri alınırken hata oluştu.")
        }
    }

    func fetchPlaylist(for id: String) {
        Task { [weak self] in
            guard let self else { return }
            do {
                let playlist = try await getPlaylistUseCase.fetchPlaylist(with: id)
                updateOnMain {
                    self.playlistModels[id] = playlist
                }
            } catch {
                handleFetchError("Çalma listesi alınırken hata oluştu.")
            }
        }
    }

    func createHorizontalScrollUIModel(_ id: String) -> HorizontalScrollViewUIModel? {
        guard let model = playlistModels[id] else { return nil }
        return HorizontalScrollViewUIModel(response: model)
    }

    private func updateScreenStateIfNeeded() {
        if newReleases != nil, userModel != nil, featuredPlayList != nil {
            screenState = .loaded
        }
    }

  private func handleFetchError(_ errorMessage: String) {
      updateOnMain {
          self.screenState = .error(errorMessage)
      }
  }
  private func updateOnMain(_ updates: @escaping () -> Void) {
      DispatchQueue.main.async { [weak self] in
          guard let self else { return }
          updates()
      }
  }
}
