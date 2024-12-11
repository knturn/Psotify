//
//  MockAuthUseCase.swift
//  PsotifyTests
//
//  Created by Turan, Kaan on 9.12.2024.
//

import Combine
@testable import Psotify

final class MockAuthUseCase: AuthUseCaseProtocol {
  var loginState: UserLoginState
  var loginPublisher: AnyPublisher<UserLoginState, Never>  {
    Just(loginState).eraseToAnyPublisher()
  }

  init(loginState: UserLoginState = .inProgress) {
    self.loginState = loginState
  }

    func refreshLoginState() async throws {
      // Not relevant for this test
    }

    func logIn(with authCode: String) async throws {
        // Not relevant for this test
    }

    func refreshToken() async throws {
        // Not relevant for this test
    }
}
