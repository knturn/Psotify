//
//  GetAlbumsUseCase.swift
//  Psotify
//
//  Created by Turan, Kaan on 26.11.2024.
//

import Foundation
protocol GetAlbumsUseCaseProtocol {
  func fetchNewReleases(limit: Int) async throws -> Albums
  func fetchOneAlbum(with id: String) async throws -> AlbumItem
}
final class GetAlbumsUseCase: GetAlbumsUseCaseProtocol {
  private let networkService: NetworkServiceProtocol

  init(networkService: NetworkServiceProtocol) {
    self.networkService = networkService
  }

  func fetchNewReleases(limit: Int) async throws -> Albums {
    guard let request = PsotifyEndpoint.newReleases(limit: String(limit)).request else {
      throw SpotifyAuthError.invalidAuthCode
    }

    let newReleases: AlbumsObjectResponse = try await networkService.fetch(request: request)
    return newReleases.albums
  }

  func fetchOneAlbum(with id: String) async throws -> AlbumItem {
    guard let request = PsotifyEndpoint.album(id: id).request else {
      throw SpotifyAuthError.invalidAuthCode
    }

    let album: AlbumItem = try await networkService.fetch(request: request)
    return album
  }
}
