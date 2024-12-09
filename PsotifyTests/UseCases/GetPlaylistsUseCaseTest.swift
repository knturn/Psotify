//
//  GetPlaylistsUseCaseTest.swift
//  PsotifyTests
//
//  Created by Turan, Kaan on 8.12.2024.
//

import XCTest
@testable import Psotify

final class GetPlaylistsUseCaseTests: BaseUseCaseTest {

    func test_fetchPlaylist_successfulResponse_returnsPlaylistDetail() async throws {
        // Given
        let expectedPlaylistName = "Sample Playlist"
        let parsedPlaylistDetail: PlayListDetailResponse = try loadMockData(from: "PlaylistDetailResponse.json", type: PlayListDetailResponse.self)

        let mock = MockNetworkService<PlayListDetailResponse>(parsedObject: parsedPlaylistDetail)
        let sut = GetPlaylistsUseCase(networkService: mock)


        // When
        let result = try await sut.fetchPlaylist(with: "playlist_id")

        // Then
        XCTAssertTrue(mock.didMessageRecieved.contains(.success))
        XCTAssertEqual(result?.name, expectedPlaylistName, "Expected playlist name to match")
    }

    func test_fetchPlaylist_failure_throwsError() async {
        // Given
        let expectedError = NSError(domain: "MockNetworkService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Simulated failure"])

        let mock = MockNetworkService<PlayListDetailResponse>(parsedObject: nil)
        let sut = GetPlaylistsUseCase(networkService: mock)

        // When & Then
        await XCTAssertThrowsErrorAsync(try await sut.fetchPlaylist(with: "playlist_id")) { error in
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, expectedError.domain, "Expected error domain to match")
            XCTAssertEqual(nsError.code, expectedError.code, "Expected error code to match")
        }
    }

    func test_fetchUserPlaylist_successfulResponse_returnsPlaylistItems() async throws {
        // Given
        let expectedPlaylistItemCount = 1
        let parsedUserPlaylists: UserPlaylistsResponse = try loadMockData(from: "UserPlaylistsResponse.json", type: UserPlaylistsResponse.self)


        let mock = MockNetworkService<UserPlaylistsResponse>(parsedObject: parsedUserPlaylists)
        let sut = GetPlaylistsUseCase(networkService: mock)

        // When
        let result = try await sut.fetchUserPlaylist()

        // Then
        XCTAssertTrue(mock.didMessageRecieved.contains(.success))
        XCTAssertEqual(result?.count, expectedPlaylistItemCount, "Expected playlist item count to match")
    }

    func test_fetchUserPlaylist_failure_throwsError() async {
        // Given
        let expectedError = NSError(domain: "MockNetworkService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Simulated failure"])

      let mock = MockNetworkService<UserPlaylistsResponse>(parsedObject: nil)
      let sut = GetPlaylistsUseCase(networkService: mock)

        // When & Then
        await XCTAssertThrowsErrorAsync(try await sut.fetchUserPlaylist()) { error in
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, expectedError.domain, "Expected error domain to match")
            XCTAssertEqual(nsError.code, expectedError.code, "Expected error code to match")
        }
    }
}
