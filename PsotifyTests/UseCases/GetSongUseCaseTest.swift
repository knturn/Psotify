//
//  GetSongUseCaseTest.swift
//  PsotifyTests
//
//  Created by Turan, Kaan on 8.12.2024.
//

import XCTest
@testable import Psotify

final class GetSongUseCaseTests: BaseUseCaseTest {

    private func makeSut(parsedObject: SongResponse?) -> (GetSongUseCase, MockNetworkService<SongResponse>) {
        let mockNetworkService = MockNetworkService<SongResponse>(parsedObject: parsedObject)
        return (GetSongUseCase(networkService: mockNetworkService), mockNetworkService)
    }

    func test_fetchSong_successfulResponse_returnsSongResponse() async throws {
        // Given
        let expectedSongName = "Sample Song"
        let parsedSongResponse: SongResponse = try loadMockData(from: "SongResponse.json", type: SongResponse.self)

        let (sut, spy) = makeSut(parsedObject: parsedSongResponse)

        // When
        let result = try await sut.fetchSong(with: "song_id")

        // Then
        XCTAssertTrue(spy.didMessageRecieved.contains(.success))
        XCTAssertEqual(result.name, expectedSongName, "Expected song name to match")
    }

    func test_fetchSong_failure_throwsError() async {
        // Given
        let expectedError = NSError(domain: "MockNetworkService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Simulated failure"])

        let (sut, _) = makeSut(parsedObject: nil)

        // When & Then
        await XCTAssertThrowsErrorAsync(try await sut.fetchSong(with: "song_id")) { error in
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, expectedError.domain, "Expected error domain to match")
            XCTAssertEqual(nsError.code, expectedError.code, "Expected error code to match")
        }
    }

  func test_fetchSong_invalidJSON_throwsParseError() async throws {
      // Given
    // invalid response for type cast error test
      let invalidResponse = PsotifyTokenResponse(
          accessToken: "dummyToken",
          tokenType: "Bearer",
          expiresIn: 3600,
          refreshToken: "dummyRefreshToken"
      )
      let mockNetworkService = MockNetworkService<PsotifyTokenResponse>(
          parsedObject: invalidResponse
      )
      let sut = GetSongUseCase(networkService: mockNetworkService)

      // When & Then
      do {
          let _: SongResponse = try await sut.fetchSong(with: "id")
          XCTFail("Expected to throw an NSError but succeeded.")
      } catch let error as NSError {
          // Check that the error domain and code match
        XCTAssertTrue(mockNetworkService.didMessageRecieved.contains(.withParseError))
      } catch {
          XCTFail("Expected NSError but received: \(error)")
      }
  }

}

