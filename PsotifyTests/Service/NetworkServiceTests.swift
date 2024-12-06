//
//  NetworkServiceTests.swift
//  PsotifyTests
//
//  Created by Turan, Kaan on 5.12.2024.
//

import XCTest
@testable import Psotify

final class NetworkServiceTests: XCTestCase {

  override func setUpWithError() throws {
    URLProtocolStub.startInterceptingRequests()
  }

  override func tearDownWithError() throws {
    URLProtocolStub.stopInterceptingRequests()
  }
  
  func test_fetch_successfulResponse_decodesModel() async throws {
      // Given
      let sut = NetworkService()
      let bundle = Bundle(for: type(of: self))

      // Load test JSON and parse it into the expected model
      guard let data = DataParsingHelper.loadJSON(from: "PsotifyTokenResponse.json", in: bundle) else {
          XCTFail("Failed to load mock JSON from file: PsotifyTokenResponse.json")
          return
      }

      guard let expectedModel: PsotifyTokenResponse = DataParsingHelper.parseData(data: data) else {
          XCTFail("Failed to parse mock JSON into PsotifyTokenResponse.")
          return
      }

      URLProtocolStub.stub(data: data, response: makeHTTPURLResponse(statusCode: 200), error: nil)

      // When
      let request = URLRequest(url: URL(string: "https://www.testurl.com")!)
      do {
          let result: PsotifyTokenResponse = try await sut.fetch(request: request)

          // Then
          XCTAssertEqual(result, expectedModel, "The result does not match the expected model.")
      } catch {
          XCTFail("Fetch operation failed with error: \(error)")
      }
  }


  func test_fetch_httpError_throwsHttpError() async {
    // Given
    let sut = NetworkService()
    let expectedError = NetworkServiceErrors.httpError(status: .notFound, data: Data())
    URLProtocolStub.stub(data: Data(), response: makeHTTPURLResponse(statusCode: 404), error: nil)

    // When
    let request = URLRequest(url: URL(string: "https://www.testurl.com")!)

    // Then
    do {
      let _: PsotifyTokenResponse = try await sut.fetch(request: request)
      XCTFail("Expected to throw an error but succeeded.")
    } catch {
      XCTAssertEqual(error as? NetworkServiceErrors, expectedError)
    }
  }

  func test_fetch_invalidJSON_throwsParseFailed() async {
    // Given
    let sut = NetworkService()
    let invalidJSON = "invalid JSON".data(using: .utf8)!
    URLProtocolStub.stub(data: invalidJSON, response: makeHTTPURLResponse(statusCode: 200), error: nil)

    // When
    let request = URLRequest(url: URL(string: "https://www.testurl.com")!)

    // Then
    do {
      let _: PsotifyTokenResponse = try await sut.fetch(request: request)
      XCTFail("Expected to throw an error but succeeded.")
    } catch {
      XCTAssertEqual(error as? NetworkServiceErrors, .parseFailed)
    }
  }

  func test_fetch_noData_throwsFetchedButEmpty() async {
    // Given
    let sut = NetworkService()
    URLProtocolStub.stub(data: nil, response: makeHTTPURLResponse(statusCode: 200), error: nil)

    // When
    let request = URLRequest(url: URL(string: "https://www.testurl.com")!)

    // Then
    do {
      let _: PsotifyTokenResponse = try await sut.fetch(request: request)
      XCTFail("Expected to throw an error but succeeded.")
    } catch {
      XCTAssertEqual(error as? NetworkServiceErrors, .fetchedButEmtpy)
    }
  }

  func test_fetch_networkError_throwsURLError() async {
    // Given
    let sut = NetworkService()
    URLProtocolStub.stub(data: nil, response: nil, error: URLError(.notConnectedToInternet))

    // When
    let request = URLRequest(url: URL(string: "https://www.testurl.com")!)

    // Then
    do {
      let _: PsotifyTokenResponse = try await sut.fetch(request: request)
      XCTFail("Expected to throw an error but succeeded.")
    } catch {
      XCTAssertEqual(error as? NetworkServiceErrors, .URLError)
    }
  }

  // MARK: - Helpers
    private func makeHTTPURLResponse(statusCode: Int) -> HTTPURLResponse {
      return HTTPURLResponse(
        url: URL(string: "https://www.testurl.com")!,
        statusCode: statusCode,
        httpVersion: nil,
        headerFields: nil
      )!
    }
  }

// MARK: - Supporting Test Structures
 extension PsotifyTokenResponse: Equatable {
  public static func == (lhs: PsotifyTokenResponse, rhs: PsotifyTokenResponse) -> Bool {
    lhs.accessToken == rhs.accessToken
  }
}

extension NetworkServiceErrors: Equatable {
  public static func == (lhs: NetworkServiceErrors, rhs: NetworkServiceErrors) -> Bool {
        switch (lhs, rhs) {
        case (.httpError(let lhsStatus, let lhsData), .httpError(let rhsStatus, let rhsData)):
            return lhsStatus == rhsStatus && lhsData == rhsData
        case (.fetchFailed, .fetchFailed):
            return true
        case (.fetchedButEmtpy, .fetchedButEmtpy):
            return true
        case (.parseFailed, .parseFailed):
            return true
        case (.URLError, .URLError):
            return true
        case (.requestError, .requestError):
            return true
        default:
            return false
        }
    }
}
