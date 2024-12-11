//
//  MainViewModelTest.swift
//  PsotifyTests
//
//  Created by Turan, Kaan on 8.12.2024.
//

import XCTest
import Combine
@testable import Psotify

final class MainViewModelTests: XCTestCase {
  func test_initialState_isInProgress() {
    // Given
    let useCase = MockAuthUseCase(loginState: .inProgress)
    let sut = MainViewModel(authUseCase: useCase)

    // Then
    XCTAssertEqual(sut.loginState, .inProgress)
  }

  func test_observeLoginState_updatesLoginState() async throws {
    // Given
    let useCase = MockAuthUseCase(loginState: .login)
    let sut = MainViewModel(authUseCase: useCase)

    // When
    let expectedLoginState: UserLoginState = .login
    try await Task.sleep(seconds: 0.1)

    // Then
    XCTAssertEqual(sut.loginState, expectedLoginState)
  }
}



