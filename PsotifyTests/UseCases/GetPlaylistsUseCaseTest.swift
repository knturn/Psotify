//
//  GetPlaylistsUseCaseTest.swift
//  PsotifyTests
//
//  Created by Turan, Kaan on 8.12.2024.
//

import XCTest
@testable import Psotify

final class GetPlaylistsUseCaseTests: BaseUseCaseTest<GetPlaylistsUseCase> {

    func test_fetchPlaylist_successfulResponse_returnsPlaylistDetail() async throws {
        // Given
        let expectedPlaylistName = "Sample PLaylist"
        let parsedPlaylistDetail: PlayListDetailResponse = try loadMockData(from: "PlaylistDetailResponse.json", type: PlayListDetailResponse.self)
        networkServiceSpy = NetworkServiceSpy(parsedObject: parsedPlaylistDetail)
        useCase = GetPlaylistsUseCase(networkService: networkServiceSpy)

        // When
        let result = try await useCase.fetchPlaylist(with: "playlist_id")

        // Then
        XCTAssertTrue(networkServiceSpy.didMessageRecieved.contains(.success))
        XCTAssertEqual(result?.name, expectedPlaylistName, "Expected playlist name to match")
    }

    func test_fetchPlaylist_failure_throwsError() async {
        // Given
        let expectedError = NSError(domain: "NetworkServiceSpy", code: 3, userInfo: [NSLocalizedDescriptionKey: "Simulated failure"])
        networkServiceSpy = NetworkServiceSpy(parsedObject: nil)
        useCase = GetPlaylistsUseCase(networkService: networkServiceSpy)

        // When & Then
      await XCTAssertThrowsErrorAsync(try await self.useCase.fetchPlaylist(with: "playlist_id")) { error in
        let nsError = error as NSError
        XCTAssertEqual(nsError.domain, expectedError.domain, "Expected error domain to match")
        XCTAssertEqual(nsError.code, expectedError.code, "Expected error code to match")
        }
    }

    func test_fetchUserPlaylist_successfulResponse_returnsPlaylistItems() async throws {
        // Given
        let expectedPlaylistItemCount = 1
        let parsedUserPlaylists: UserPlaylistsResponse = try loadMockData(from: "UserPlaylistsResponse.json", type: UserPlaylistsResponse.self)
        networkServiceSpy = NetworkServiceSpy(parsedObject: parsedUserPlaylists)
        useCase = GetPlaylistsUseCase(networkService: networkServiceSpy)

        // When
        let result = try await useCase.fetchUserPlaylist()

        // Then
        XCTAssertTrue(networkServiceSpy.didMessageRecieved.contains(.success))
      XCTAssertEqual(result?.count, expectedPlaylistItemCount, "Expected playlist item count to match")
    }

    func test_fetchUserPlaylist_failure_throwsError() async {
        // Given
        let expectedError = NSError(domain: "NetworkServiceSpy", code: 3, userInfo: [NSLocalizedDescriptionKey: "Simulated failure"])
        networkServiceSpy = NetworkServiceSpy(parsedObject: nil)
        useCase = GetPlaylistsUseCase(networkService: networkServiceSpy)

        // When & Then
      await XCTAssertThrowsErrorAsync(try await self.useCase.fetchUserPlaylist()) { error in
        let nsError = error as NSError
        XCTAssertEqual(nsError.domain, expectedError.domain, "Expected error domain to match")
        XCTAssertEqual(nsError.code, expectedError.code, "Expected error code to match")
        }
    }
}
