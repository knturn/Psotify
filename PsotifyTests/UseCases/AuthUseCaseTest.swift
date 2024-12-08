//
//  AuthUseCaseTest.swift
//  PsotifyTests
//
//  Created by Turan, Kaan on 6.12.2024.
//

import XCTest
import Combine
@testable import Psotify

final class AuthUseCaseTests: XCTestCase {
    private var mockNetworkService: MockNetworkService<PsotifyTokenResponse>!
    private var mockKeychainService: MockKeyChainService!
    private var mockUserDefaultsService: MockUserDefaultsService!
    private var authUseCase: AuthUseCase!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        mockKeychainService = MockKeyChainService()
        mockUserDefaultsService = MockUserDefaultsService()
        authUseCase = AuthUseCase(
            networkService: mockNetworkService,
            keychainService: mockKeychainService,
            userDefaultsService: mockUserDefaultsService
        )
        cancellables = []
    }

    override func tearDown() {
        mockNetworkService = nil
        mockKeychainService = nil
        mockUserDefaultsService = nil
        authUseCase = nil
        cancellables = nil
        super.tearDown()
    }

    func testLogInSuccess() async throws {
        // Given
        let authCode = "validAuthCode"
        let tokenResponse = PsotifyTokenResponse(
            accessToken: "validAccessToken",
            tokenType: "Bearer",
            expiresIn: 3600,
            refreshToken: "validRefreshToken"
        )

        let mockData = try JSONEncoder().encode(tokenResponse)
        mockNetworkService.mockData = mockData

        // When
        try await authUseCase.logIn(with: authCode)

        // Then
        XCTAssertEqual(mockKeychainService.savedData[KeychainServiceKeys.authCode.rawValue], authCode.data(using: .utf8))
        let savedTokenModel: PsotifyTokenStorageModel? = mockUserDefaultsService.getElement(
            forKey: UserDefaultsServiceKeys.tokenStorage.rawValue,
            type: PsotifyTokenStorageModel.self
        )
        XCTAssertNotNil(savedTokenModel)
        XCTAssertEqual(savedTokenModel?.accessToken, "validAccessToken")
    }

    func testLogInFailure() async throws {
        // Given
        let authCode = "invalidAuthCode"
        mockNetworkService.shouldReturnError = true
        mockNetworkService.mockError = SpotifyAuthError.invalidAuthCode

        // When/Then
        await XCTAssertThrowsErrorAsync(
          try await self.authUseCase.logIn(with: authCode)
        ) { error in
            XCTAssertEqual(error as? SpotifyAuthError, .invalidAuthCode)
        }
    }

    func testRefreshTokenSuccess() async throws {
        // Given
        let refreshToken = "validRefreshToken"
        let tokenResponse = PsotifyTokenResponse(
            accessToken: "newAccessToken",
            tokenType: "Bearer",
            expiresIn: 3600,
            refreshToken: refreshToken
        )

        let mockData = try JSONEncoder().encode(tokenResponse)
        mockNetworkService.mockData = mockData

        let tokenStorageModel = PsotifyTokenStorageModel(response: .init(accessToken: "oldAccessToken", tokenType: "Bearer", expiresIn: -3600, refreshToken: "validRefreshToken"))

        try await mockUserDefaultsService.saveElement(model: tokenStorageModel, forKey: UserDefaultsServiceKeys.tokenStorage.rawValue)

        // When
        try await authUseCase.refreshToken()

        // Then
        let savedTokenModel: PsotifyTokenStorageModel? = mockUserDefaultsService.getElement(
            forKey: UserDefaultsServiceKeys.tokenStorage.rawValue,
            type: PsotifyTokenStorageModel.self
        )
        XCTAssertNotNil(savedTokenModel)
        XCTAssertEqual(savedTokenModel?.accessToken, "newAccessToken")
    }

    func testRefreshTokenFailure() async throws {
        // Given
        mockNetworkService.shouldReturnError = true
        mockNetworkService.mockError = SpotifyAuthError.tokenUnavailable

        // When/Then
        await XCTAssertThrowsErrorAsync(
          try await self.authUseCase.refreshToken()
        ) { error in
            XCTAssertEqual(error as? SpotifyAuthError, .tokenUnavailable)
        }
    }

    func testCheckLoginStateWhenTokenValid() async throws {
        // Given
        let tokenResponse = PsotifyTokenResponse(
            accessToken: "validAccessToken",
            tokenType: "Bearer",
            expiresIn: 3600,
            refreshToken: "validRefreshToken"
        )
        let tokenStorage = PsotifyTokenStorageModel(response: tokenResponse)

        try await mockUserDefaultsService.saveElement(
            defaults: .standard,
            model: tokenStorage,
            forKey: UserDefaultsServiceKeys.tokenStorage.rawValue
        )

        // When
        try await authUseCase.checkLoginState()

        // Then
        let receivedState = await getStateFromPublisher(authUseCase.loginPublisher)
        XCTAssertEqual(receivedState, .login)
    }

    func testCheckLoginStateWhenTokenExpired() async throws {
        // Given
        let tokenResponse = PsotifyTokenResponse(
            accessToken: "expiredAccessToken",
            tokenType: "Bearer",
            expiresIn: -3600,
            refreshToken: "validRefreshToken"
        )
        let expiredTokenStorage = PsotifyTokenStorageModel(response: tokenResponse)

        try await mockUserDefaultsService.saveElement(
            defaults: .standard,
            model: expiredTokenStorage,
            forKey: UserDefaultsServiceKeys.tokenStorage.rawValue
        )

        // When
        try await authUseCase.checkLoginState()

        // Then
        let receivedState = await getStateFromPublisher(authUseCase.loginPublisher)
        XCTAssertEqual(receivedState, .logout)
    }

    // Helper to retrieve the latest state from a Combine publisher
    private func getStateFromPublisher(_ publisher: AnyPublisher<UserLoginState, Never>) async -> UserLoginState {
        await withCheckedContinuation { continuation in
            publisher
                .sink { state in
                    continuation.resume(returning: state)
                }
                .store(in: &cancellables)
        }
    }
}

 extension SpotifyAuthError: Equatable {
   public static func ==(lhs: SpotifyAuthError, rhs: SpotifyAuthError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidClientID, .invalidClientID),
             (.invalidClientSecret, .invalidClientSecret),
             (.invalidAuthCode, .invalidAuthCode),
             (.invalidRedirectURI, .invalidRedirectURI),
             (.tokenUnavailable, .tokenUnavailable),
             (.refreshTokenExpired, .refreshTokenExpired):
            return true

        case (.tokenFetchError(let lhsError), .tokenFetchError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription

        case (.networkError(let lhsError), .networkError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription

        case (.serverError(let lhsStatusCode, let lhsMessage), .serverError(let rhsStatusCode, let rhsMessage)):
            return lhsStatusCode == rhsStatusCode && lhsMessage == rhsMessage

        case (.invalidRequest(let lhsMessage), .invalidRequest(let rhsMessage)):
            return lhsMessage == rhsMessage

        default:
            return false
        }
    }
}

