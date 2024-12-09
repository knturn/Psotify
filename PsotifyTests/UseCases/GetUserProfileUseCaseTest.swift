//
//  GetUserProfileUseCaseTest.swift
//  PsotifyTests
//
//  Created by Turan, Kaan on 6.12.2024.
//

import XCTest
@testable import Psotify

final class GetUserProfileUseCaseTests: BaseUseCaseTest {

  private func makeSut(parsedObject: SpotifyUserProfile?) -> (GetUserProfileUseCase, MockNetworkService<SpotifyUserProfile>) {
    let mock = MockNetworkService<SpotifyUserProfile>(parsedObject: parsedObject)
    return (GetUserProfileUseCase(networkService: mock), mock)
  }

  func test_fetchUserInfo_successfulResponse_returnsUserProfile() async throws {
    // Given
    let expectedUsername = "John Doe"
    let parsedObject: SpotifyUserProfile = try loadMockData(from: "UserProfileResponse.json", type: SpotifyUserProfile.self)

    let (sut, spy) = makeSut(parsedObject: parsedObject)

    // When
    let result = try await sut.fetchUserInfo()

    // Then
    XCTAssertTrue(spy.didMessageRecieved.contains(.success))
    XCTAssertEqual(result.displayName, expectedUsername, "Expected username to match")
  }

  func test_fetchUserInfo_failure_throwsError() async {
    // Given
    let expectedError = NSError(domain: "MockNetworkService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Simulated failure"])

    let (sut, _) = makeSut(parsedObject: nil)

    // When & Then
    await XCTAssertThrowsErrorAsync(try await sut.fetchUserInfo()) { error in
      let nsError = error as NSError
      XCTAssertEqual(nsError.domain, expectedError.domain, "Expected error domain to match")
      XCTAssertEqual(nsError.code, expectedError.code, "Expected error code to match")
    }
  }

  func test_fetchUserInfo_invalidJSON_throwsParseError() async throws {
    // Given
    let invalidResponse = PsotifyTokenResponse(
      accessToken: "dummyToken",
      tokenType: "Bearer",
      expiresIn: 3600,
      refreshToken: "dummyRefreshToken"
    )
    let mockNetworkService = MockNetworkService<PsotifyTokenResponse>(
      parsedObject: invalidResponse
    )
    let sut = GetUserProfileUseCase(networkService: mockNetworkService)

    // When & Then
    do {
      let _: SpotifyUserProfile = try await sut.fetchUserInfo()
      XCTFail("Expected to throw an NSError but succeeded.")
    } catch let error as NSError {
      // Check that the error domain and code match
      XCTAssertTrue(mockNetworkService.didMessageRecieved.contains(.withParseError))
    } catch {
      XCTFail("Expected NSError but received: \(error)")
    }
  }
}

