//
//  GetUserSavedTracksUseCaseTest.swift
//  PsotifyTests
//
//  Created by Turan, Kaan on 8.12.2024.
//

import XCTest
@testable import Psotify

final class GetUserSavedTracksUseCaseTests: BaseUseCaseTest<GetUserSavedTracksUseCase> {

    func test_fetchTopTracks_successfulResponse_returnsUserTracksResponse() async throws {
        // Given
        let expectedTrackAlbumID = "5JBOWYaxcyNzWuq3PewTMk"
        let mockUserTracksResponse: UserTracksResponse = try loadMockData(from: "UserTracksResponse.json", type: UserTracksResponse.self)
        networkServiceSpy = NetworkServiceSpy(parsedObject: mockUserTracksResponse)
        useCase = GetUserSavedTracksUseCase(networkService: networkServiceSpy)

        // When
        let result = try await useCase.fetchTopTracks()

        // Then
        XCTAssertTrue(networkServiceSpy.didMessageRecieved.contains(.success))
      XCTAssertEqual(result.items.first?.track.album.id, expectedTrackAlbumID, "Expected track album id to match")
    }

    func test_fetchTopTracks_failure_throwsError() async {
        // Given
      let expectedError = NSError(domain: "NetworkServiceSpy", code: 3, userInfo: [NSLocalizedDescriptionKey: "Simulated failure"])
        networkServiceSpy = NetworkServiceSpy(parsedObject: nil)
        useCase = GetUserSavedTracksUseCase(networkService: networkServiceSpy)

        // When & Then
        await XCTAssertThrowsErrorAsync(try await self.useCase.fetchTopTracks()) { error in
          let nsError = error as NSError
          XCTAssertEqual(nsError.domain, expectedError.domain, "Expected error domain to match")
          XCTAssertEqual(nsError.code, expectedError.code, "Expected error code to match")
        }
    }

    func test_fetchTopTracks_invalidJSON_throwsParseError() async {
        // Given
        let invalidJSON = "Invalid JSON".data(using: .utf8)!
        URLProtocolStub.stub(data: invalidJSON, response: makeHTTPURLResponse(statusCode: 200), error: nil)

        let request = URLRequest(url: URL(string: "https://www.testurl.com")!)
        let sut = NetworkService()

        // When & Then
        do {
            let _: UserTracksResponse = try await sut.fetch(request: request)
            XCTFail("Expected to throw a parse error but succeeded.")
        } catch {
            XCTAssertEqual(error as? NetworkServiceErrors, .parseFailed, "Expected parse error to match")
        }
    }
}
