//
//  GetUserTopTracksUseCase.swift
//  Psotify
//
//  Created by Turan, Kaan on 4.12.2024.
//

import Foundation
protocol GetUserTopTracksUseCaseProtocol {
  func fetchTopTracks() async throws -> UserTracksResponse
}

struct GetUserTopTracksUseCase: GetUserTopTracksUseCaseProtocol {
  private let networkService: NetworkServiceProtocol

  init(networkService: NetworkServiceProtocol) {
    self.networkService = networkService
  }

  func fetchTopTracks() async throws -> UserTracksResponse {
    guard let request = PsotifyEndpoint.userTopTracks.request else {
      throw SpotifyAuthError.invalidAuthCode
    }

    let album: UserTracksResponse = try await networkService.fetch(request: request)
    return album
  }
}
