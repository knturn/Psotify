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

    init(
        getUserProfileUseCase: GetUserProfileUseCaseProtocol = AppDIContainer.shared.resolve(GetUserProfileUseCaseProtocol.self),
        getAlbumsUseCase: GetAlbumsUseCaseProtocol = AppDIContainer.shared.resolve(GetAlbumsUseCaseProtocol.self),
        getPlaylistUseCase: GetPlaylistsUseCaseProtocol = AppDIContainer.shared.resolve(GetPlaylistsUseCaseProtocol.self)
    ) {
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

    @MainActor
    private func fetchUserProfile() async {
        do {
            let userModel = try await getUserProfileUseCase.fetchUserInfo()
            self.userModel = userModel
            self.updateScreenStateIfNeeded()
        } catch {
            self.screenState = .error("Kullanıcı bilgileri alınırken hata oluştu.")
        }
    }

    @MainActor
    private func fetchNewReleases() async {
        do {
            let albums = try await getAlbumsUseCase.fetchNewReleases(limit: 6)
            self.newReleases = albums.items
            self.updateScreenStateIfNeeded()
        } catch {
            self.screenState = .error("Yeni albümler alınırken hata oluştu.")
        }
    }

    @MainActor
    private func fetchUserPlaylists() async {
        do {
            let playlists = try await getPlaylistUseCase.fetchUserPlaylist()
            self.featuredPlayList = playlists
            self.updateScreenStateIfNeeded()
        } catch {
            self.screenState = .error("Çalma listeleri alınırken hata oluştu.")
        }
    }

    @MainActor
    func fetchPlaylist(for id: String) {
        Task { [weak self] in
            guard let self else { return }
            do {
                let playlist = try await getPlaylistUseCase.fetchPlaylist(with: id)
                self.playlistModels[id] = playlist
            } catch {
                self.screenState = .error("Çalma listeleri alınırken hata oluştu.")
            }
        }
    }

    func createHorizontalScrollViewUIModel(for playlistID: String, onTap: @escaping (String) -> Void) -> HorizontalScrollViewUIModel? {
        guard let playlistModel = getPlaylistModel(playlistID) else {
            return nil
        }
        return HorizontalScrollViewUIModel(response: playlistModel, onTap: onTap)
    }

    func getPlaylistModel(_ id: String) -> PlayListDetailResponse? {
        return playlistModels[id]
    }

    private func updateScreenStateIfNeeded() {
        if newReleases != nil, userModel != nil, featuredPlayList != nil {
            screenState = .loaded
        }
    }
}
