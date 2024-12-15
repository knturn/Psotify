//
//  GetSongUseCase.swift
//  Psotify
//
//  Created by Turan, Kaan on 29.11.2024.
//

import Foundation

protocol GetSongUseCaseProtocol {
  func fetchSong(with id: String) async throws -> SongResponse
}

final class GetSongUseCase: GetSongUseCaseProtocol {
  private let networkService: NetworkServiceProtocol

  init(networkService: NetworkServiceProtocol) {
    self.networkService = networkService
  }

  func fetchSong(with id: String) async throws -> SongResponse {
    guard let request = PsotifyEndpoint.track(id: id).request else {
      throw SpotifyAuthError.invalidAuthCode
    }

    let album: SongResponse = try await networkService.fetch(request: request)
    return album
  }
}
