//
//  GetSongUseCaseTest.swift
//  PsotifyTests
//
//  Created by Turan, Kaan on 8.12.2024.
//

import XCTest
@testable import Psotify

final class GetSongUseCaseTests: BaseUseCaseTest {
    func test_fetchSong_successfulResponse_returnsSongResponse() async throws {
        // Given
        let expectedSongName = "Sample Song"
        let parsedSongResponse: SongResponse = try loadMockData(from: "SongResponse.json", type: SongResponse.self)

        let (sut, mock) = createSUT(parsedObject: parsedSongResponse) { mock in
          GetSongUseCase(networkService: mock)
        }

        // When
        let result = try await sut.fetchSong(with: "song_id")

        // Then
        XCTAssertTrue(mock.recievedMessages.contains(.success))
        XCTAssertEqual(result.name, expectedSongName, "Expected song name to match")
    }

    func test_fetchSong_failure_throwsError() async {
        // Given
        let expectedError = NSError(domain: "MockNetworkService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Simulated failure"])

      let (sut, _) = createSUT { mock in
        GetSongUseCase(networkService: mock)
      }

        // When & Then
        await XCTAssertThrowsErrorAsync(try await sut.fetchSong(with: "song_id")) { error in
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, expectedError.domain, "Expected error domain to match")
            XCTAssertEqual(nsError.code, expectedError.code, "Expected error code to match")
        }
    }

  func test_fetchSong_invalidJSON_throwsParseError() async throws {
      // Given
      let invalidResponse = PsotifyTokenResponse(
          accessToken: "dummyToken",
          tokenType: "Bearer",
          expiresIn: 3600,
          refreshToken: "dummyRefreshToken"
      )

     let (sut, mock) = createSUT(parsedObject: invalidResponse) { mock in  // invalid response for type cast error test
       GetSongUseCase(networkService: mock)
     }

      // When & Then
      do {
          let _: SongResponse = try await sut.fetchSong(with: "id")
          XCTFail("Expected to throw an NSError but succeeded.")
      } catch _ as NSError {
          // Check that the error domain and code match
        XCTAssertTrue(mock.recievedMessages.contains(.withParseError))
      } catch {
          XCTFail("Expected NSError but received: \(error)")
      }
  }

}

