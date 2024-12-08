//
//  GetSongUseCaseTest.swift
//  PsotifyTests
//
//  Created by Turan, Kaan on 8.12.2024.
//

import XCTest
@testable import Psotify

final class GetSongUseCaseTests: BaseUseCaseTest<GetSongUseCase> {

    func test_fetchSong_successfulResponse_returnsSongResponse() async throws {
        // Given
        let expectedSongName = "Sample Song"
        let parsedSongResponse: SongResponse = try loadMockData(from: "SongResponse.json", type: SongResponse.self)
        networkServiceSpy = NetworkServiceSpy(parsedObject: parsedSongResponse)
        useCase = GetSongUseCase(networkService: networkServiceSpy)

        // When
        let result = try await useCase.fetchSong(with: "song_id")

        // Then
        XCTAssertTrue(networkServiceSpy.didMessageRecieved.contains(.success))
        XCTAssertEqual(result.name, expectedSongName, "Expected song name to match")
    }

    func test_fetchSong_failure_throwsError() async {
        // Given
        let expectedError = NSError(domain: "NetworkServiceSpy", code: 3, userInfo: [NSLocalizedDescriptionKey: "Simulated failure"])
        networkServiceSpy = NetworkServiceSpy(parsedObject: nil)
        useCase = GetSongUseCase(networkService: networkServiceSpy)

        // When & Then
        await XCTAssertThrowsErrorAsync(try await self.useCase.fetchSong(with: "song_id")) { error in
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, expectedError.domain, "Expected error domain to match")
            XCTAssertEqual(nsError.code, expectedError.code, "Expected error code to match")
        }
    }

    func test_fetchSong_invalidJSON_throwsParseError() async {
        // Given
        let invalidJSON = "Invalid JSON".data(using: .utf8)!
        URLProtocolStub.stub(data: invalidJSON, response: makeHTTPURLResponse(statusCode: 200), error: nil)

        let request = URLRequest(url: URL(string: "https://www.testurl.com")!)
        let sut = NetworkService()

        // When & Then
        do {
            let _: SongResponse = try await sut.fetch(request: request)
            XCTFail("Expected to throw a parse error but succeeded.")
        } catch {
            XCTAssertEqual(error as? NetworkServiceErrors, .parseFailed, "Expected parse error to match")
        }
    }
}
