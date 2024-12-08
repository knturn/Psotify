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
class GetPlaylistsUseCase: GetPlaylistsUseCaseProtocol {
  private let networkService: NetworkServiceProtocol

  init(networkService: NetworkServiceProtocol) {
    self.networkService = networkService
  }
  
  func fetchPlaylist(with id: String) async throws -> PlayListDetailResponse? {

    guard let request = PsotifyEndpoint.playlist(id: id).request else {
      throw SpotifyAuthError.invalidAuthCode
    }

    let playlistsResponse: PlayListDetailResponse = try await networkService.fetch(request: request)
    return playlistsResponse
  }

  func fetchUserPlaylist() async throws -> [PlaylistItem]? {
    guard let request = PsotifyEndpoint.userPlaylists.request else {
      throw SpotifyAuthError.invalidAuthCode
    }

    let playlistsResponse: UserPlaylistsResponse = try await networkService.fetch(request: request)
    return playlistsResponse.items
  }
}
