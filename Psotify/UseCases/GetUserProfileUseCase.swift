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
    guard let accessToken = UserDefaultsService.getElement(forKey: UserDefaultsServiceKeys.tokenStorage.rawValue, type: PsotifyTokenStorageModel.self)?.accessToken else {
        throw SpotifyAuthError.tokenUnavailable
    }
    guard let request = PsotifyEndpoint.userProfile(accessToken: accessToken).request else {
      throw SpotifyAuthError.invalidAuthCode
    }

    let userResponse: SpotifyUserProfile = try await networkService.fetch(request: request)
    return userResponse
  }
}
