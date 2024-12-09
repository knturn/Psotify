//
//  MockNetworkService.swift
//  PsotifyTests
//
//  Created by Turan, Kaan on 6.12.2024.
//

import Foundation
@testable import Psotify

final class MockNetworkService<ResponseType: Codable>: NetworkServiceProtocol {
  private let parsedObject: Codable?
  let errorToThrow: Error?
  private(set) var didMessageRecieved: [MockNetworkServiceMessages?] = .init()

  init(parsedObject: Codable? = nil, errorToThrow: Error? = nil) {
    self.parsedObject = parsedObject
    self.errorToThrow = errorToThrow
  }

  func fetch<T>(request: URLRequest) async throws -> T where T: Decodable {

    if let error = errorToThrow {
      didMessageRecieved.append(.returnWantedError)
      throw error
    }

    guard let response = parsedObject as? T else {
      didMessageRecieved.append(.withParseError)
      throw NSError(domain: "MockNetworkService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid data type"])
    }
    didMessageRecieved.append(.success)
    return response


  }
}

enum MockNetworkServiceMessages {
  case returnWantedError
  case success
  case withParseError
  case withLoadJSONError
}