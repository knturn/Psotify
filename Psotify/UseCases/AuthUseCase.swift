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
    enum Constants {
        static let authCodeKey = "authCode"
        static let userStorageKey = "userAccessInfo"
    }
    static let shared: AuthUseCaseProtocol = AuthUseCase()
    private let networkService: NetworkServiceProtocol = NetworkService()
    
    private var loginStatePublisher = CurrentValueSubject<UserLoginState, Never>(.inProgress)
    
    var loginPublisher: AnyPublisher<UserLoginState, Never>  {
        loginStatePublisher.eraseToAnyPublisher()
    }
    
    private init() { }

    func logIn(with authCode: String) async throws {
        do {
            // 1. Auth kodunu kaydet
            try saveAuthCode(authCode)
            
            // 2. Token al
            try await fetchToken()
            
            // 3. Giriş başarılı
            loginStatePublisher.send(.login)
        } catch {
            loginStatePublisher.send(.logout)
            throw SpotifyAuthError.invalidAuthCode
        }
    }
    
    func refreshToken() async throws {
        let model = UserDefaultsService.getElement(forKey: Constants.userStorageKey, type: PsotifyTokenStorageModel.self)
        let refreshToken = model?.refreshToken
        do {
            guard let refreshToken = model?.refreshToken else {
                throw SpotifyAuthError.tokenUnavailable
            }
            
            // Refresh token endpoint çağrısı
            guard let request = PsotifyEndpoint.refreshToken(refreshToken: refreshToken).request else {
                throw SpotifyAuthError.tokenUnavailable
            }
            
            let tokenResponse: PsotifyTokenResponse = try await networkService.fetch(request: request)
            try await UserDefaultsService.saveElement(model: tokenResponse.self, forKey: Constants.userStorageKey)
            loginStatePublisher.send(.login)
        } catch {
            loginStatePublisher.send(.logout)
            throw SpotifyAuthError.tokenUnavailable
        }
    }
    
    func checkLoginState() async throws {
        do {
            if self.isTokenExpired() {
                try await refreshToken()
            } else if self.getTokenModel() == nil {
                try await fetchToken()
            }
            
            loginStatePublisher.send(.login)
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
        KeyChainService.remove(key: Constants.authCodeKey)
        try KeyChainService.save(key: Constants.authCodeKey, data: authCodeData)
    }
    
    private func fetchToken() async throws {
        guard let authCode = KeyChainService.get(key: Constants.authCodeKey)?.toString() else {
            throw SpotifyAuthError.tokenUnavailable
        }
        
        guard let request = PsotifyEndpoint.token(code: authCode).request else {
            throw SpotifyAuthError.tokenUnavailable
        }
        
        let tokenResponse: PsotifyTokenResponse = try await networkService.fetch(request: request)
        try await UserDefaultsService.saveElement(model: tokenResponse.self, forKey: Constants.userStorageKey)
    }
    
    private func isTokenExpired() -> Bool {
        guard let tokenModel = self.getTokenModel(),
              tokenModel.refreshToken != nil else { return false }
        return Date() >= tokenModel.expireDate
    }
    
    private  func getTokenModel() -> PsotifyTokenStorageModel? {
        guard let model = UserDefaultsService.getElement(forKey: Constants.userStorageKey, type: PsotifyTokenStorageModel.self) else {return nil}
        return model
    }
}
