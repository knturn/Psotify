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
    func refreshLoginState() async throws
    var loginPublisher: AnyPublisher<UserLoginState, Never> { get }
}

final class AuthUseCase: AuthUseCaseProtocol {
  var loginPublisher: AnyPublisher<UserLoginState, Never>  {
      loginState.eraseToAnyPublisher()
  }

    private let networkService: NetworkServiceProtocol
    private let keychainService: KeyChainServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let loginState: CurrentValueSubject<UserLoginState, Never>

  init(networkService: NetworkServiceProtocol,
         keychainService: KeyChainServiceProtocol = AppDIContainer.shared.resolve(KeyChainServiceProtocol.self),
       userDefaultsService: UserDefaultsServiceProtocol = UserDefaultsService.shared,
         loginState: CurrentValueSubject<UserLoginState, Never> = CurrentValueSubject<UserLoginState, Never>(.inProgress)) {
        self.networkService = networkService
        self.keychainService = keychainService
        self.userDefaultsService = userDefaultsService
        self.loginState = loginState
    }

    func logIn(with authCode: String) async throws {
        do {
            // 1. Save the authentication code
            try saveAuthCode(authCode)
            
            // 2. Retrieve the token
            try await fetchToken()
            
            // 3. Login successful
            loginState.send(.login)
        } catch {
            // Handle login failure and set state to logout
            loginState.send(.logout)
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
          loginState.send(.login)
      } catch {
          throw SpotifyAuthError.tokenUnavailable
      }
  }

  func refreshLoginState() async throws {
      // Retrieve the token model
      guard let tokenModel = getTokenModel(), tokenModel.refreshToken != nil else {
          // If there's no token or no refresh token, send logout state
          loginState.send(.logout)
          return
      }

      // Check if the token is expired
      if Date() >= tokenModel.expireDate {
          do {
              // If expired, try to refresh the token
              try await handleTokenRefresh()
          } catch {
              // If refreshing the token fails, send logout state
              loginState.send(.logout)
              throw error
          }
          return
      }

      // If the token is valid and not expired, send login state
      loginState.send(.login)
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

  private func handleTokenRefresh() async throws {
      do {
          try await refreshToken()
          loginState.send(.login)
      } catch {
          loginState.send(.logout)
      }
  }
}
