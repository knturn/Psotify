//
//  GetAlbumsUseCaseTest.swift
//  PsotifyTests
//
//  Created by Turan, Kaan on 8.12.2024.
//

import XCTest
@testable import Psotify

final class GetAlbumsUseCaseTests: BaseUseCaseTest<GetAlbumsUseCase> {

    func test_fetchNewReleases_successfulResponse_returnsAlbums() async throws {
        // Given
        let expectedAlbumItemCount = 1
        let parsedAlbums: AlbumsObjectResponse = try loadMockData(from: "AlbumsResponse.json", type: AlbumsObjectResponse.self)
        networkServiceSpy = NetworkServiceSpy(parsedObject: parsedAlbums)
        useCase = GetAlbumsUseCase(networkService: networkServiceSpy)

        // When
        let result = try await useCase.fetchNewReleases(limit: 1)

        // Then
        XCTAssertTrue(networkServiceSpy.didMessageRecieved.contains(.success))
        XCTAssertEqual(result.items.count, expectedAlbumItemCount, "Expected album item count")
    }

    func test_fetchNewReleases_failure_throwsError() async {
        // Given
        let expectedError = NSError(domain: "NetworkServiceSpy", code: 3, userInfo: [NSLocalizedDescriptionKey: "Simulated failure"])
        networkServiceSpy = NetworkServiceSpy(parsedObject: nil)
        useCase = GetAlbumsUseCase(networkService: networkServiceSpy)

        // When & Then
        await XCTAssertThrowsErrorAsync(try await self.useCase.fetchNewReleases(limit: 1)) { error in
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, expectedError.domain, "Expected error domain to match")
            XCTAssertEqual(nsError.code, expectedError.code, "Expected error code to match")
        }
    }

    func test_fetchOneAlbum_successfulResponse_returnsAlbumItem() async throws {
        // Given
        let expectedAlbumName = "Sample Album"
        let parsedAlbumItem: AlbumItem = try loadMockData(from: "AlbumItemResponse.json", type: AlbumItem.self)
        networkServiceSpy = NetworkServiceSpy(parsedObject: parsedAlbumItem)
        useCase = GetAlbumsUseCase(networkService: networkServiceSpy)

        // When
        let result = try await useCase.fetchOneAlbum(with: "album_id")

        // Then
        XCTAssertTrue(networkServiceSpy.didMessageRecieved.contains(.success))
        XCTAssertEqual(result.name, expectedAlbumName, "Expected album name to match")
    }

    func test_fetchOneAlbum_failure_throwsError() async {
        // Given
        let expectedError = NSError(domain: "NetworkServiceSpy", code: 3, userInfo: [NSLocalizedDescriptionKey: "Simulated failure"])
        networkServiceSpy = NetworkServiceSpy(parsedObject: nil)
        useCase = GetAlbumsUseCase(networkService: networkServiceSpy)

        // When & Then
        await XCTAssertThrowsErrorAsync(try await self.useCase.fetchOneAlbum(with: "album_id")) { error in
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, expectedError.domain, "Expected error domain to match")
            XCTAssertEqual(nsError.code, expectedError.code, "Expected error code to match")
        }
    }

    func test_fetchNewReleases_invalidJSON_throwsParseError() async {
        // Given
        let invalidJSON = "Invalid JSON".data(using: .utf8)!
        URLProtocolStub.stub(data: invalidJSON, response: makeHTTPURLResponse(statusCode: 200), error: nil)

        let request = URLRequest(url: URL(string: "https://www.testurl.com")!)
        let sut = NetworkService()

        // When & Then
        do {
            let _: Albums = try await sut.fetch(request: request)
            XCTFail("Expected to throw a parse error but succeeded.")
        } catch {
            XCTAssertEqual(error as? NetworkServiceErrors, .parseFailed, "Expected parse error to match")
        }
    }
}
