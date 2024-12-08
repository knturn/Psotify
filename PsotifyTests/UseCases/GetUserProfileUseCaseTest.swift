//
//  GetUserProfileUseCaseTest.swift
//  PsotifyTests
//
//  Created by Turan, Kaan on 6.12.2024.
//

import XCTest
@testable import Psotify

final class GetUserProfileUseCaseTests: BaseUseCaseTest<GetUserProfileUseCase> {

    override func setUpWithError() throws {
        try super.setUpWithError()
        let parsedObject: SpotifyUserProfile = try loadMockData(
            from: "UserProfileResponse.json",
            type: SpotifyUserProfile.self
        )
        networkServiceSpy = NetworkServiceSpy(parsedObject: parsedObject)
        useCase = GetUserProfileUseCase(networkService: networkServiceSpy)
    }

    func test_fetchUserInfo_successfulResponse_returnsUserProfile() async throws {
        // Given
        let expectedUsername = "John Doe"

        // When
        let result = try await useCase.fetchUserInfo()

        // Then
        XCTAssertTrue(networkServiceSpy.didMessageRecieved.contains(.success))
        XCTAssertEqual(result.displayName, expectedUsername, "Expected username to match")
    }

    func test_fetchUserInfo_failure_throwsError() async {
        // Given
        let expectedError = NSError(domain: "NetworkServiceSpy", code: 3, userInfo: [NSLocalizedDescriptionKey: "Simulated failure"])
        networkServiceSpy = NetworkServiceSpy(parsedObject: nil)
        useCase = GetUserProfileUseCase(networkService: networkServiceSpy)

        // When & Then
        await XCTAssertThrowsErrorAsync(try await self.useCase.fetchUserInfo()) { error in
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, expectedError.domain, "Expected error domain to match")
            XCTAssertEqual(nsError.code, expectedError.code, "Expected error code to match")
        }
    }

    func test_fetchUserInfo_invalidJSON_throwsParseError() async {
        // Given
        let invalidJSON = "Invalid JSON".data(using: .utf8)!
        URLProtocolStub.stub(data: invalidJSON, response: makeHTTPURLResponse(statusCode: 200), error: nil)

        let request = URLRequest(url: URL(string: "https://www.testurl.com")!)
        let sut = NetworkService()

        // When & Then
        do {
            let _: SpotifyUserProfile = try await sut.fetch(request: request)
            XCTFail("Expected to throw a parse error but succeeded.")
        } catch {
            XCTAssertEqual(error as? NetworkServiceErrors, .parseFailed, "Expected parse error to match")
        }
    }
}
