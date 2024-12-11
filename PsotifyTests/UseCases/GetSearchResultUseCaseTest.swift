//
//  GetSearchResultUseCaseTest.swift
//  PsotifyTests
//
//  Created by Turan, Kaan on 8.12.2024.
//

import XCTest
@testable import Psotify

final class GetSearchResultUseCaseTests: BaseUseCaseTest {
    func test_fetchResult_successfulResponse_returnsSearchResponse() async throws {
        // Given
        let expectedAlbumName = "Sample Album"
        let mockSearchResponse: SearchResponse = try loadMockData(from: "AlbumsResponse.json", type: SearchResponse.self)

        let (sut, mock) = createSUT(parsedObject: mockSearchResponse) { mock in
          GetSearchResultUseCase(networkService: mock)
        }
        // When
        let result = try await sut.fetchResult(with: "query", for: ["album"])

        // Then
        XCTAssertTrue(mock.recievedMessages.contains(.success))
        XCTAssertEqual(result.albums?.items.first?.name, expectedAlbumName, "Expected album name to match")
    }

    func test_fetchResult_failure_throwsError() async {
        // Given
        let expectedError = NSError(domain: "MockNetworkService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Simulated failure"])

      let (sut, _) = createSUT { mock in
        GetSearchResultUseCase(networkService: mock)
      }

        // When & Then
        await XCTAssertThrowsErrorAsync(try await sut.fetchResult(with: "query", for: ["album"])) { error in
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, expectedError.domain, "Expected error domain to match")
            XCTAssertEqual(nsError.code, expectedError.code, "Expected error code to match")
        }
    }

  func test_fetchResult_invalidJSON_throwsParseError() async throws {
      // Given
      let invalidResponse = PsotifyTokenResponse(
          accessToken: "dummyToken",
          tokenType: "Bearer",
          expiresIn: 3600,
          refreshToken: "dummyRefreshToken"
      )
      let (sut, mock) = createSUT(parsedObject: invalidResponse) { mock in
          GetSearchResultUseCase(networkService: mock)
      }

      // When 
      await XCTAssertThrowsErrorAsync(
          try await sut.fetchResult(with: "", for: ["query"])
      ) { error in
        // Then
          XCTAssertTrue(mock.recievedMessages.contains(.withParseError), "Expected .withParseError message in mock")
      }
  }

}
