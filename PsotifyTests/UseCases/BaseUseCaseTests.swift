//
//  BaseUseCaseTests.swift
//  PsotifyTests
//
//  Created by Turan, Kaan on 8.12.2024.
//

import Foundation
import XCTest
@testable import Psotify

class BaseUseCaseTest: XCTestCase {
    let bundle = Bundle(for: BaseUseCaseTest.self)
  
    override func setUpWithError() throws {
        URLProtocolStub.startInterceptingRequests()
    }

    override func tearDownWithError() throws {
        URLProtocolStub.stopInterceptingRequests()
    }

    func loadMockData<T: Decodable>(from fileName: String, type: T.Type) throws -> T {
        guard let jsonData = DataParsingHelper.loadJSON(from: fileName, in: bundle) else {
            XCTFail("Failed to load JSON data")
            throw NSError(domain: "BaseUseCaseTest", code: 1, userInfo: nil)
        }
        guard let parsedObject: T = DataParsingHelper.parseData(data: jsonData) else {
            XCTFail("Failed to decode JSON data")
            throw NSError(domain: "BaseUseCaseTest", code: 2, userInfo: nil)
        }
        return parsedObject
    }

    func makeHTTPURLResponse(statusCode: Int) -> HTTPURLResponse {
        return HTTPURLResponse(
            url: anyUrl,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }

  func createSUT<T: Codable, U>(
      parsedObject: T? = nil as MockResponse?,
      useCaseInitializer: (MockNetworkService<T>) -> U
  ) -> (sut: U, mock: MockNetworkService<T>) {
      let mock = MockNetworkService(parsedObject: parsedObject)
      let sut = useCaseInitializer(mock)
      return (sut, mock)
  }

  private var anyUrl: URL {
    URL(string: "https://www.testurl.com")!
  }
}

struct MockResponse: Codable {
    let id: Int
}
