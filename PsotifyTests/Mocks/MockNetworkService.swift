//
//  MockNetworkService.swift
//  PsotifyTests
//
//  Created by Turan, Kaan on 6.12.2024.
//

import Foundation
@testable import Psotify

final class MockNetworkService<ResponseType: Codable>: NetworkServiceProtocol {
  private let parsedObject: ResponseType?
  let errorToThrow: Error?
  private(set) var recievedMessages: [MockNetworkServiceMessages] = .init()

  init(parsedObject: ResponseType? = nil, errorToThrow: Error? = nil) {
    self.parsedObject = parsedObject
    self.errorToThrow = errorToThrow
  }

  func fetch<T>(request: URLRequest) async throws -> T where T: Decodable {

    if let error = errorToThrow {
      recievedMessages.append(.returnWantedError)
      throw error
    }

    guard let response = parsedObject as? T else {
      recievedMessages.append(.withParseError)
      throw NSError(domain: "MockNetworkService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid data type"])
    }
    recievedMessages.append(.success)
    return response


  }
}

enum MockNetworkServiceMessages {
  case returnWantedError
  case success
  case withParseError
  case withLoadJSONError
}
