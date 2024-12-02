//
//  GetSearchResultUseCase.swift
//  Psotify
//
//  Created by Turan, Kaan on 2.12.2024.
//

import Foundation

protocol GetSearchResultProtocol {
  func fetchResult(with query: String, for types: [String]) async throws -> SearchResponse
}

struct GetSearchResultUseCase: GetSearchResultProtocol {
  private let networkService: NetworkServiceProtocol

  init(networkService: NetworkServiceProtocol) {
    self.networkService = networkService
  }

  func fetchResult(with query: String, for types: [String]) async throws -> SearchResponse {
    guard let request = PsotifyEndpoint.search(query: query, types: types).request else {
      throw SpotifyAuthError.invalidAuthCode
    }

    let album: SearchResponse = try await networkService.fetch(request: request)
    return album
  }
}
