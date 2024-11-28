//
//  GetPlaylistsUseCase.swift
//  Psotify
//
//  Created by Turan, Kaan on 27.11.2024.
//

import Foundation
protocol GetPlaylistsUseCaseProtocol {
  func fetchPlaylist(with id: String) async throws -> PlayListDetailResponse?
  func fetchUserPlaylist() async throws -> [PlaylistItem]?
}
struct GetPlaylistsUseCase: GetPlaylistsUseCaseProtocol {
  private let networkService: NetworkServiceProtocol
  private let accessToken = UserDefaultsService.getElement(forKey: UserDefaultsServiceKeys.tokenStorage.rawValue, type: PsotifyTokenStorageModel.self)?.accessToken

  init(networkService: NetworkServiceProtocol) {
    self.networkService = networkService
  }
  
  func fetchPlaylist(with id: String) async throws -> PlayListDetailResponse? {
    guard let accessToken else {
      throw SpotifyAuthError.tokenUnavailable
    }
    guard let request = PsotifyEndpoint.playlist(accessToken: accessToken, id: id).request else {
      throw SpotifyAuthError.invalidAuthCode
    }

    let playlistsResponse: PlayListDetailResponse = try await networkService.fetch(request: request)
    return playlistsResponse
  }

  func fetchUserPlaylist() async throws -> [PlaylistItem]? {
    guard let accessToken else {
      throw SpotifyAuthError.tokenUnavailable
    }
    guard let request = PsotifyEndpoint.userPlaylists(accessToken: accessToken).request else {
      throw SpotifyAuthError.invalidAuthCode
    }

    let playlistsResponse: UserPlaylistsResponse = try await networkService.fetch(request: request)
    return playlistsResponse.items
  }
}
