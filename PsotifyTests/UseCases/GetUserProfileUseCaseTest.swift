//
//  GetUserProfileUseCaseTest.swift
//  PsotifyTests
//
//  Created by Turan, Kaan on 6.12.2024.
//

import XCTest
@testable import Psotify

final class GetUserProfileUseCaseTests: BaseUseCaseTest {

  func test_fetchUserInfo_successfulResponse_returnsUserProfile() async throws {
    // Given
    let expectedUsername = "John Doe"
    let parsedObject: SpotifyUserProfile = try loadMockData(from: "UserProfileResponse.json", type: SpotifyUserProfile.self)

    let (sut, mock) = createSUT(parsedObject: parsedObject) { mock in
      GetUserProfileUseCase(networkService: mock)
    }

    // When
    let result = try await sut.fetchUserInfo()

    // Then
    XCTAssertTrue(mock.recievedMessages.contains(.success))
    XCTAssertEqual(result.displayName, expectedUsername, "Expected username to match")
  }

  func test_fetchUserInfo_failure_throwsError() async {
    // Given
    let expectedError = NSError(domain: "MockNetworkService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Simulated failure"])

    let (sut, _) = createSUT { mock in
      GetUserProfileUseCase(networkService: mock)
    }

    // When
    await XCTAssertThrowsErrorAsync(try await sut.fetchUserInfo()) { error in
      let nsError = error as NSError
    // Then
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
    let (sut, mock) = createSUT(parsedObject: invalidResponse) { mock in
      GetUserProfileUseCase(networkService: mock)
    }

    // When
    do {
      let _: SpotifyUserProfile = try await sut.fetchUserInfo()
      XCTFail("Expected to throw an NSError but succeeded.")
    } catch _ as NSError {
    // Then
      XCTAssertTrue(mock.recievedMessages.contains(.withParseError))
    } catch {
      XCTFail("Expected NSError but received: \(error)")
    }
  }
}

