//
//  GetAlbumsUseCase.swift
//  Psotify
//
//  Created by Turan, Kaan on 26.11.2024.
//

import Foundation
protocol GetAlbumsUseCaseProtocol {
  func fetchNewReleases(limit: Int) async throws -> Albums
}
struct GetAlbumsUseCase: GetAlbumsUseCaseProtocol {
  private let networkService: NetworkServiceProtocol
  private let accessToken = UserDefaultsService.getElement(forKey: UserDefaultsServiceKeys.tokenStorage.rawValue, type: PsotifyTokenStorageModel.self)?.accessToken

  init(networkService: NetworkServiceProtocol) {
    self.networkService = networkService
  }

  func fetchNewReleases(limit: Int) async throws -> Albums {
    guard let accessToken else {
      throw SpotifyAuthError.tokenUnavailable
    }
    guard let request = PsotifyEndpoint.newReleases(accessToken: accessToken, limit: String(limit)).request else {
      throw SpotifyAuthError.invalidAuthCode
    }

    let newReleases: AlbumsObjectResponse = try await networkService.fetch(request: request)
    return newReleases.albums
  }
}
