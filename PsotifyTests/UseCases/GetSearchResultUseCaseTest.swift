//
//  GetSearchResultUseCaseTest.swift
//  PsotifyTests
//
//  Created by Turan, Kaan on 8.12.2024.
//

import XCTest
@testable import Psotify

final class GetSearchResultUseCaseTests: BaseUseCaseTest<GetSearchResultUseCase> {

    func test_fetchResult_successfulResponse_returnsSearchResponse() async throws {
        // Given
        let expectedAlbumName = "Sample Album"
        let mockSearchResponse: SearchResponse = try loadMockData(from: "AlbumsResponse.json", type: SearchResponse.self)
        networkServiceSpy = NetworkServiceSpy(parsedObject: mockSearchResponse)
        useCase = GetSearchResultUseCase(networkService: networkServiceSpy)

        // When
        let result = try await useCase.fetchResult(with: "query", for: ["album"])

        // Then
        XCTAssertTrue(networkServiceSpy.didMessageRecieved.contains(.success))
        XCTAssertEqual(result.albums?.items.first?.name, expectedAlbumName, "Expected album name to match")
    }

    func test_fetchResult_failure_throwsError() async {
        // Given
      let expectedError = NSError(domain: "NetworkServiceSpy", code: 3, userInfo: [NSLocalizedDescriptionKey: "Simulated failure"])
        networkServiceSpy = NetworkServiceSpy(parsedObject: nil)
        useCase = GetSearchResultUseCase(networkService: networkServiceSpy)

        // When & Then
        await XCTAssertThrowsErrorAsync(try await self.useCase.fetchResult(with: "query", for: ["album"])) { error in
          let nsError = error as NSError
          XCTAssertEqual(nsError.domain, expectedError.domain, "Expected error domain to match")
          XCTAssertEqual(nsError.code, expectedError.code, "Expected error code to match")

        }
    }

    func test_fetchResult_invalidJSON_throwsParseError() async {
        // Given
        let invalidJSON = "Invalid JSON".data(using: .utf8)!
        URLProtocolStub.stub(data: invalidJSON, response: makeHTTPURLResponse(statusCode: 200), error: nil)

        let request = URLRequest(url: URL(string: "https://www.testurl.com")!)
        let sut = NetworkService()

        // When & Then
        do {
            let _: SearchResponse = try await sut.fetch(request: request)
            XCTFail("Expected to throw a parse error but succeeded.")
        } catch {
          XCTAssertEqual(error as? NetworkServiceErrors, .parseFailed, "Expected parse error to match")
        }
    }
}
