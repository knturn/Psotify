//
//  GetSearchResultUseCaseTest.swift
//  PsotifyTests
//
//  Created by Turan, Kaan on 8.12.2024.
//

import XCTest
@testable import Psotify

final class GetSearchResultUseCaseTests: BaseUseCaseTest {

    private func makeSut(parsedObject: SearchResponse?) -> (GetSearchResultUseCase, MockNetworkService<SearchResponse>) {
        let mockNetworkService = MockNetworkService<SearchResponse>(parsedObject: parsedObject)
        return (GetSearchResultUseCase(networkService: mockNetworkService), mockNetworkService)
    }

    func test_fetchResult_successfulResponse_returnsSearchResponse() async throws {
        // Given
        let expectedAlbumName = "Sample Album"
        let mockSearchResponse: SearchResponse = try loadMockData(from: "AlbumsResponse.json", type: SearchResponse.self)

        let (sut, spy) = makeSut(parsedObject: mockSearchResponse)

        // When
        let result = try await sut.fetchResult(with: "query", for: ["album"])

        // Then
        XCTAssertTrue(spy.didMessageRecieved.contains(.success))
        XCTAssertEqual(result.albums?.items.first?.name, expectedAlbumName, "Expected album name to match")
    }

    func test_fetchResult_failure_throwsError() async {
        // Given
        let expectedError = NSError(domain: "MockNetworkService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Simulated failure"])

        let (sut, _) = makeSut(parsedObject: nil)

        // When & Then
        await XCTAssertThrowsErrorAsync(try await sut.fetchResult(with: "query", for: ["album"])) { error in
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, expectedError.domain, "Expected error domain to match")
            XCTAssertEqual(nsError.code, expectedError.code, "Expected error code to match")
        }
    }

  func test_fetchResult_invalidJSON_throwsParseError() async throws {
    // Invalid response to mock networkService for test typeCasting issues
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
      let sut = GetSearchResultUseCase(networkService: mockNetworkService)

      // When & Then
      do {
        let _: SearchResponse = try await sut.fetchResult(with: "", for: ["query"])
          XCTFail("Expected to throw an NSError but succeeded.")
      } catch let error as NSError {
          // Check that the error domain and code match
        XCTAssertTrue(mockNetworkService.didMessageRecieved.contains(.withParseError))
      } catch {
          XCTFail("Expected NSError but received: \(error)")
      }
  }

}
