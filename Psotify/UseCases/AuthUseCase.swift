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
    
    private let loginStatePublisher: CurrentValueSubject<UserLoginState, Never>
    
    var loginPublisher: AnyPublisher<UserLoginState, Never>  {
        loginStatePublisher.eraseToAnyPublisher()
    }
    
    init(networkService: NetworkServiceProtocol, loginStatePublisher: CurrentValueSubject<UserLoginState, Never> = CurrentValueSubject<UserLoginState, Never>(.inProgress)) {
        self.networkService = networkService
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
        let model = UserDefaultsService.getElement(forKey:  UserDefaultsServiceKeys.tokenStorage.rawValue, type: PsotifyTokenStorageModel.self)
        do {
            guard let refreshToken = model?.refreshToken else {
                throw SpotifyAuthError.tokenUnavailable
            }
            
            guard let request = PsotifyEndpoint.refreshToken(refreshToken: refreshToken).request else {
                throw SpotifyAuthError.tokenUnavailable
            }
            
            let tokenResponse: PsotifyTokenResponse = try await networkService.fetch(request: request)
          try await UserDefaultsService.saveElement(model: tokenResponse.self, forKey: UserDefaultsServiceKeys.tokenStorage.rawValue)
            loginStatePublisher.send(.login)
        } catch {
            throw SpotifyAuthError.tokenUnavailable
        }
    }
    
    func checkLoginState() async throws {
        do {
            guard !self.isTokenExpired() else {
              do {
                try await refreshToken()
                 loginStatePublisher.send(.login)
              } catch {
                loginStatePublisher.send(.logout)
              }
                return
            }
          if KeyChainService.get(key: KeychainServiceKeys.authCode.rawValue) != nil {
                try await fetchToken()
                loginStatePublisher.send(.login)
            } else {
                loginStatePublisher.send(.logout)
            }
        } catch {
            loginStatePublisher.send(.logout)
            throw error
        }
    }
}

// MARK: - Private Methods
extension AuthUseCase {
    private func saveAuthCode(_ authCode: String) throws {
        guard let authCodeData = authCode.data(using: .utf8) else {
            throw SpotifyAuthError.invalidAuthCode
        }
            KeyChainService.remove(key: KeychainServiceKeys.authCode.rawValue)
        try KeyChainService.save(key: KeychainServiceKeys.authCode.rawValue, data: authCodeData)
    }
    
    private func fetchToken() async throws {
        guard let authCode = KeyChainService.get(key: KeychainServiceKeys.authCode.rawValue)?.toString() else {
            throw SpotifyAuthError.tokenUnavailable
        }
        
        guard let request = PsotifyEndpoint.token(code: authCode).request else {
            throw SpotifyAuthError.tokenUnavailable
        }
        
        let tokenResponse: PsotifyTokenResponse = try await networkService.fetch(request: request)
        let tokenStorage : PsotifyTokenStorageModel = .init(response: tokenResponse)
      try await UserDefaultsService.saveElement(model: tokenStorage.self, forKey: UserDefaultsServiceKeys.tokenStorage.rawValue)
    }
    
    private func isTokenExpired() -> Bool {
        guard let tokenModel = self.getTokenModel(),
              tokenModel.refreshToken != nil else { return false }
        return Date() >= tokenModel.expireDate
    }
    
    private  func getTokenModel() -> PsotifyTokenStorageModel? {
      guard let model = UserDefaultsService.getElement(forKey: UserDefaultsServiceKeys.tokenStorage.rawValue, type: PsotifyTokenStorageModel.self) else {return nil}
        return model
    }
}
