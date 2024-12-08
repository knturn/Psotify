//
//  AuthUseCase.swift
//  Psotify
//
//  Created by Turan, Kaan on 18.11.2024.
//

import Foundation
import Combine

protocol AuthUseCaseProtocol {
    func logIn(with authCode: String) async throws
    func refreshToken() async throws
    func checkLoginState() async throws
    var loginPublisher: AnyPublisher<UserLoginState, Never> { get }
}

final class AuthUseCase: AuthUseCaseProtocol {
    private let networkService: NetworkServiceProtocol
    private let keychainService: KeyChainServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol

    private let loginStatePublisher: CurrentValueSubject<UserLoginState, Never>
    
    var loginPublisher: AnyPublisher<UserLoginState, Never>  {
        loginStatePublisher.eraseToAnyPublisher()
    }

  init(networkService: NetworkServiceProtocol,
         keychainService: KeyChainServiceProtocol = AppDIContainer.shared.resolve(KeyChainServiceProtocol.self),
       userDefaultsService: UserDefaultsServiceProtocol = UserDefaultsService.shared,
         loginStatePublisher: CurrentValueSubject<UserLoginState, Never> = CurrentValueSubject<UserLoginState, Never>(.inProgress)) {
        self.networkService = networkService
        self.keychainService = keychainService
        self.userDefaultsService = userDefaultsService
        self.loginStatePublisher = loginStatePublisher
    }

    func logIn(with authCode: String) async throws {
        do {
            // 1. Save the authentication code
            try saveAuthCode(authCode)
            
            // 2. Retrieve the token
            try await fetchToken()
            
            // 3. Login successful
            loginStatePublisher.send(.login)
        } catch {
            // Handle login failure and set state to logout
            loginStatePublisher.send(.logout)
            throw SpotifyAuthError.invalidAuthCode
        }
    }
    
  func refreshToken() async throws {
      let model = getTokenModel()
      do {
          guard let refreshToken = model?.refreshToken else {
              throw SpotifyAuthError.tokenUnavailable
          }

          guard let request = PsotifyEndpoint.refreshToken(refreshToken: refreshToken).request else {
              throw SpotifyAuthError.tokenUnavailable
          }

          let tokenResponse: PsotifyTokenResponse = try await networkService.fetch(request: request)
      
          let tokenStorage: PsotifyTokenStorageModel = .init(response: tokenResponse)

          try await userDefaultsService.saveElement(
              defaults: .standard,
              model: tokenStorage,
              forKey: UserDefaultsServiceKeys.tokenStorage.rawValue
          )
          loginStatePublisher.send(.login)
      } catch {
          throw SpotifyAuthError.tokenUnavailable
      }
  }

  func checkLoginState() async throws {
      // Retrieve the token model
      guard let tokenModel = getTokenModel(), tokenModel.refreshToken != nil else {
          // If there's no token or no refresh token, send logout state
          loginStatePublisher.send(.logout)
          return
      }

      // Check if the token is expired
      if Date() >= tokenModel.expireDate {
          do {
              // If expired, try to refresh the token
              try await handleTokenRefresh()
          } catch {
              // If refreshing the token fails, send logout state
              loginStatePublisher.send(.logout)
              throw error
          }
          return
      }

      // If the token is valid and not expired, send login state
      loginStatePublisher.send(.login)
  }

  private func handleTokenRefresh() async throws {
      do {
          try await refreshToken()
          loginStatePublisher.send(.login)
      } catch {
          loginStatePublisher.send(.logout)
      }
  }

  private func hasValidAuthCodeAndToken() -> Bool {
      let hasAuthCode = keychainService.get(key: KeychainServiceKeys.authCode.rawValue) != nil
      let hasTokenModel = getTokenModel() != nil
      return hasAuthCode && hasTokenModel
  }
}


// MARK: - Private Methods
extension AuthUseCase {
    private func saveAuthCode(_ authCode: String) throws {
        guard let authCodeData = authCode.data(using: .utf8) else {
            throw SpotifyAuthError.invalidAuthCode
        }
      keychainService.remove(key: KeychainServiceKeys.authCode.rawValue)
        try keychainService.save(key: KeychainServiceKeys.authCode.rawValue, data: authCodeData)
    }
    
  private func fetchToken() async throws {
      guard let authCode = keychainService.get(key: KeychainServiceKeys.authCode.rawValue)?.toString() else {
          throw SpotifyAuthError.tokenUnavailable
      }

      guard let request = PsotifyEndpoint.token(code: authCode).request else {
          throw SpotifyAuthError.tokenUnavailable
      }

      let tokenResponse: PsotifyTokenResponse = try await networkService.fetch(request: request)
      let tokenStorage: PsotifyTokenStorageModel = .init(response: tokenResponse)
      try await userDefaultsService.saveElement(
          defaults: .standard,
          model: tokenStorage,
          forKey: UserDefaultsServiceKeys.tokenStorage.rawValue
      )
  }
    
  private func getTokenModel() -> PsotifyTokenStorageModel? {
      return userDefaultsService.getElement(
          defaults: .standard,
          forKey: UserDefaultsServiceKeys.tokenStorage.rawValue,
          type: PsotifyTokenStorageModel.self
      )
  }

}
