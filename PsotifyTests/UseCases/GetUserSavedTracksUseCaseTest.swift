//
//  GetUserSavedTracksUseCaseTest.swift
//  PsotifyTests
//
//  Created by Turan, Kaan on 8.12.2024.
//

import XCTest
@testable import Psotify

final class GetUserSavedTracksUseCaseTests: BaseUseCaseTest {
    func test_fetchTopTracks_successfulResponse_returnsUserTracksResponse() async throws {
        // Given
        let expectedTrackAlbumID = "5JBOWYaxcyNzWuq3PewTMk"
        let mockUserTracksResponse: UserTracksResponse = try loadMockData(from: "UserTracksResponse.json", type: UserTracksResponse.self)

        let (sut, mock) = createSUT(parsedObject: mockUserTracksResponse) { mock in
          GetUserSavedTracksUseCase(networkService: mock)
        }

        // When
        let result = try await sut.fetchTopTracks()

        // Then
        XCTAssertTrue(mock.recievedMessages.contains(.success))
        XCTAssertEqual(result.items.first?.track.album.id, expectedTrackAlbumID, "Expected track album id to match")
    }

    func test_fetchTopTracks_failure_throwsError() async {
        // Given
        let expectedError = NSError(domain: "MockNetworkService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Simulated failure"])

        let (sut, _) = createSUT { mock in
          GetUserSavedTracksUseCase(networkService: mock)
        }

        // When
        await XCTAssertThrowsErrorAsync(try await sut.fetchTopTracks()) { error in
            let nsError = error as NSError
        // Then
            XCTAssertEqual(nsError.domain, expectedError.domain, "Expected error domain to match")
            XCTAssertEqual(nsError.code, expectedError.code, "Expected error code to match")
        }
    }

  func test_fetchTopTracks_invalidJSON_throwsParseError() async throws {
      // Given
      let invalidResponse = PsotifyTokenResponse(
          accessToken: "dummyToken",
          tokenType: "Bearer",
          expiresIn: 3600,
          refreshToken: "dummyRefreshToken"
      )

      let (sut, mock) = createSUT(parsedObject: invalidResponse) { mock in
          GetUserSavedTracksUseCase(networkService: mock)
      }

      // When
      await XCTAssertThrowsErrorAsync(
          try await sut.fetchTopTracks()
      ) { error in
        // Then
          XCTAssertTrue(mock.recievedMessages.contains(.withParseError), "Expected .withParseError message in mock")
      }
  }
}
