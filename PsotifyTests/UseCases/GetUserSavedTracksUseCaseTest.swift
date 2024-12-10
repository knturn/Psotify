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

        let (sut, mock) = createSUT { mock in
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
    // Invalid response to mock networkService for test typeCasting issues
      // Given
      let invalidResponse = PsotifyTokenResponse(
          accessToken: "dummyToken",
          tokenType: "Bearer",
          expiresIn: 3600,
          refreshToken: "dummyRefreshToken"
      )

      let (sut, mock) = createSUT(parsedObject: invalidResponse) { mock in // Geçersiz yanıt (UserTracksResponse bekleniyor)
        GetUserSavedTracksUseCase(networkService: mock)
      }

      // When
      do {
          let _: UserTracksResponse = try await sut.fetchTopTracks()
          XCTFail("Expected to throw an NSError but succeeded.")
      } catch let error as NSError {
        // Then
          XCTAssertTrue(mock.recievedMessages.contains(.withParseError))
      } catch {
          XCTFail("Expected NSError but received: \(error)")
      }
  }

}
