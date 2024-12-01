//
//  GetUserProfileUseCase.swift
//  Psotify
//
//  Created by Turan, Kaan on 26.11.2024.
//

import Foundation
protocol GetUserProfileUseCaseProtocol {
  func fetchUserInfo() async throws -> SpotifyUserProfile
}

struct GetUserProfileUseCase: GetUserProfileUseCaseProtocol {
  private let networkService: NetworkServiceProtocol

  init(networkService: NetworkServiceProtocol) {
      self.networkService = networkService
  }

  func fetchUserInfo() async throws -> SpotifyUserProfile {

    guard let request = PsotifyEndpoint.userProfile.request else {
      throw SpotifyAuthError.invalidAuthCode
    }

    let userResponse: SpotifyUserProfile = try await networkService.fetch(request: request)
    return userResponse
  }
}
