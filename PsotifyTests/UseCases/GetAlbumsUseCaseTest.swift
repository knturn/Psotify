//
//  GetAlbumsUseCaseTest.swift
//  PsotifyTests
//
//  Created by Turan, Kaan on 8.12.2024.
//

import XCTest
@testable import Psotify

final class GetAlbumsUseCaseTests: BaseUseCaseTest {
    func test_fetchNewReleases_successfulResponse_returnsAlbums() async throws {
        // Given
        let expectedAlbumItemCount = 1
        let parsedAlbums: AlbumsObjectResponse = try loadMockData(from: "AlbumsResponse.json", type: AlbumsObjectResponse.self)


      let (sut, mock) = createSUT(parsedObject: parsedAlbums) { mock in
              GetAlbumsUseCase(networkService: mock)
          }

        // When
        let result = try await sut.fetchNewReleases(limit: 1)

        // Then
        XCTAssertTrue(mock.recievedMessages.contains(.success))
        XCTAssertEqual(result.items.count, expectedAlbumItemCount, "Expected album item count")
    }

    func test_fetchNewReleases_failure_throwsError() async {
        // Given
        let expectedError = NSError(domain: "MockNetworkService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Simulated failure"])

      let (sut, _) = createSUT { mock in
              GetAlbumsUseCase(networkService: mock)
          }

        // When
        await XCTAssertThrowsErrorAsync(try await sut.fetchNewReleases(limit: 1)) { error in
            let nsError = error as NSError
        // Then
            XCTAssertEqual(nsError.domain, expectedError.domain, "Expected error domain to match")
            XCTAssertEqual(nsError.code, expectedError.code, "Expected error code to match")
        }
    }

    func test_fetchOneAlbum_successfulResponse_returnsAlbumItem() async throws {
        // Given
        let expectedAlbumName = "Sample Album"
        let parsedAlbumItem: AlbumItem = try loadMockData(from: "AlbumItemResponse.json", type: AlbumItem.self)

        let (sut, mock) = createSUT(parsedObject: parsedAlbumItem) { mock in
            GetAlbumsUseCase(networkService: mock)
        }

        // When
        let result = try await sut.fetchOneAlbum(with: "album_id")

        // Then
        XCTAssertTrue(mock.recievedMessages.contains(.success))
        XCTAssertEqual(result.name, expectedAlbumName, "Expected album name to match")
    }

    func test_fetchOneAlbum_failure_throwsError() async {
        // Given
        let expectedError = NSError(domain: "MockNetworkService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Simulated failure"])

        let (sut, _) = createSUT { mock in
              GetAlbumsUseCase(networkService: mock)
          }

        // When
        await XCTAssertThrowsErrorAsync(try await sut.fetchOneAlbum(with: "album_id")) { error in
            let nsError = error as NSError
        // Then
            XCTAssertEqual(nsError.domain, expectedError.domain, "Expected error domain to match")
            XCTAssertEqual(nsError.code, expectedError.code, "Expected error code to match")
        }
    }

  func test_fetchNewReleases_invalidJSON_throwsParseError() async throws {
      // Given
      let invalidResponse = PsotifyTokenResponse(
          accessToken: "dummyToken",
          tokenType: "Bearer",
          expiresIn: 3600,
          refreshToken: "dummyRefreshToken"
      )

    let (sut, mock) = createSUT(parsedObject: invalidResponse) { mock in // Invalid response return for type casting test
          GetAlbumsUseCase(networkService: mock)
      }

      // When & Then
      do {
          let _: Albums = try await sut.fetchNewReleases(limit: 10)
          XCTFail("Expected to throw an NSError but succeeded.")
      } catch _ as NSError {
          // Check that the error domain and code match
        XCTAssertTrue(mock.recievedMessages.contains(.withParseError))
      } catch {
          XCTFail("Expected NSError but received: \(error)")
      }
  }

}
