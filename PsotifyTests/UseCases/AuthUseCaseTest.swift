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
    func testLogInSuccess() async throws {
        // Given
      let tokenResponse = PsotifyTokenResponse(
          accessToken: "validAccessToken",
          tokenType: "Bearer",
          expiresIn: 3600,
          refreshToken: "validRefreshToken"
      )

        let mockNetworkService = MockNetworkService<PsotifyTokenResponse>(parsedObject: tokenResponse)
        let mockKeychainService = MockKeyChainService()
        let mockUserDefaultsService = MockUserDefaultsService()
        let authUseCase = AuthUseCase(
            networkService: mockNetworkService,
            keychainService: mockKeychainService,
            userDefaultsService: mockUserDefaultsService
        )

        let authCode = "validAuthCode"

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
      let mockNetworkService = MockNetworkService<PsotifyTokenResponse>(
          parsedObject: nil,
          errorToThrow: SpotifyAuthError.invalidAuthCode
      )
      let mockKeychainService = MockKeyChainService()
      let mockUserDefaultsService = MockUserDefaultsService()
      let authUseCase = AuthUseCase(
          networkService: mockNetworkService,
          keychainService: mockKeychainService,
          userDefaultsService: mockUserDefaultsService
      )

      let authCode = "invalidAuthCode"

      // When/Then
      await XCTAssertThrowsErrorAsync(
          try await authUseCase.logIn(with: authCode)
      ) { error in
          XCTAssertEqual(error as? SpotifyAuthError, .invalidAuthCode)
      }

      XCTAssertEqual(mockNetworkService.didMessageRecieved, [.returnWantedError])
  }


  func testRefreshTokenSuccess() async throws {
      // Given
      let tokenResponse = PsotifyTokenResponse(
          accessToken: "newAccessToken",
          tokenType: "Bearer",
          expiresIn: 3600,
          refreshToken: "validRefreshToken"
      )
      let mockNetworkService = MockNetworkService<PsotifyTokenResponse>(
          parsedObject: tokenResponse
      )
      let mockKeychainService = MockKeyChainService()
      let mockUserDefaultsService = MockUserDefaultsService()
      let authUseCase = AuthUseCase(
          networkService: mockNetworkService,
          keychainService: mockKeychainService,
          userDefaultsService: mockUserDefaultsService
      )

      let tokenStorageModel = PsotifyTokenStorageModel(
          response: .init(
              accessToken: "oldAccessToken",
              tokenType: "Bearer",
              expiresIn: -3600, // Token expired
              refreshToken: "validRefreshToken"
          )
      )

      try await mockUserDefaultsService.saveElement(
          model: tokenStorageModel,
          forKey: UserDefaultsServiceKeys.tokenStorage.rawValue
      )

      // When
      try await authUseCase.refreshToken()

      // Then
      let savedTokenModel: PsotifyTokenStorageModel? = mockUserDefaultsService.getElement(
          forKey: UserDefaultsServiceKeys.tokenStorage.rawValue,
          type: PsotifyTokenStorageModel.self
      )
      XCTAssertNotNil(savedTokenModel)
      XCTAssertEqual(savedTokenModel?.accessToken, "newAccessToken")
      XCTAssertEqual(mockNetworkService.didMessageRecieved, [.success])
  }


  func testRefreshTokenFailure() async throws {
      // Given
      let mockNetworkService = MockNetworkService<PsotifyTokenResponse>(
          parsedObject: nil,
          errorToThrow: SpotifyAuthError.tokenUnavailable
      )
      let mockKeychainService = MockKeyChainService()
      let mockUserDefaultsService = MockUserDefaultsService()
      let authUseCase = AuthUseCase(
          networkService: mockNetworkService,
          keychainService: mockKeychainService,
          userDefaultsService: mockUserDefaultsService
      )

      // When/Then
      await XCTAssertThrowsErrorAsync(
          try await authUseCase.refreshToken()
      ) { error in
          XCTAssertEqual(error as? SpotifyAuthError, .tokenUnavailable)
      }
  }


  func test_checkLoginState_whenTokenValid() async throws {
      // Given
      let tokenResponse = PsotifyTokenResponse(
          accessToken: "validAccessToken",
          tokenType: "Bearer",
          expiresIn: 3600,
          refreshToken: "validRefreshToken"
      )
      let mockNetworkService = MockNetworkService<PsotifyTokenResponse>(
          parsedObject: tokenResponse
      )
      let mockKeychainService = MockKeyChainService()
      let mockUserDefaultsService = MockUserDefaultsService()
      let authUseCase = AuthUseCase(
          networkService: mockNetworkService,
          keychainService: mockKeychainService,
          userDefaultsService: mockUserDefaultsService
      )

      let tokenStorage = PsotifyTokenStorageModel(response: tokenResponse)

      try await mockUserDefaultsService.saveElement(
          model: tokenStorage,
          forKey: UserDefaultsServiceKeys.tokenStorage.rawValue
      )

      // When
      try await authUseCase.checkLoginState()

      // Then
      let receivedState = await getStateFromPublisher(authUseCase.loginPublisher)
      XCTAssertEqual(receivedState, .login)
      XCTAssertTrue(mockNetworkService.didMessageRecieved.isEmpty) // no need fetch request did not triggered
  }


  func test_checkLoginState_whenTokenExpired() async throws {
      // Given
      let tokenResponse = PsotifyTokenResponse(
          accessToken: "expiredAccessToken",
          tokenType: "Bearer",
          expiresIn: -3600, // Token is expired
          refreshToken: "validRefreshToken"
      )
      let mockNetworkService = MockNetworkService<PsotifyTokenResponse>(
          parsedObject: nil
      )
      let mockKeychainService = MockKeyChainService()
      let mockUserDefaultsService = MockUserDefaultsService()
      let authUseCase = AuthUseCase(
          networkService: mockNetworkService,
          keychainService: mockKeychainService,
          userDefaultsService: mockUserDefaultsService
      )

      let expiredTokenStorage = PsotifyTokenStorageModel(response: tokenResponse)

      try await mockUserDefaultsService.saveElement(
          model: expiredTokenStorage,
          forKey: UserDefaultsServiceKeys.tokenStorage.rawValue
      )

      // When
      try await authUseCase.checkLoginState()

      // Then
      let receivedState = await getStateFromPublisher(authUseCase.loginPublisher)
      XCTAssertEqual(receivedState, .logout)

    XCTAssertTrue(mockNetworkService.didMessageRecieved.contains(.withParseError))
  }


    // Helper to retrieve the latest state from a Combine publisher
    private func getStateFromPublisher(_ publisher: AnyPublisher<UserLoginState, Never>) async -> UserLoginState {
       var cancellables: Set<AnyCancellable> = []
       return await withCheckedContinuation { continuation in
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
