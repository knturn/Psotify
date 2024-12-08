//
//  NetworkServiceSpy.swift
//  PsotifyTests
//
//  Created by Turan, Kaan on 6.12.2024.
//

import Foundation
@testable import Psotify

final class NetworkServiceSpy: NetworkServiceProtocol {
  private(set) var didMessageRecieved: [NetworkServiceSpyMessages?] = .init()
    private let parsedObject: Codable?
    private let errorToThrow: Error?

    init(parsedObject: Codable?, errorToThrow: Error? = nil) {
        self.parsedObject = parsedObject
        self.errorToThrow = errorToThrow
    }

    func fetch<T>(request: URLRequest) async throws -> T where T: Decodable {
        if let error = errorToThrow {
          didMessageRecieved.append(.returnWantedError)
            throw error
        }
        guard let result = parsedObject as? T else {
          didMessageRecieved.append(.withParseError)
            throw NSError(domain: "NetworkServiceSpy", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid data type"])
        }
      didMessageRecieved.append(.success)
        return result
    }
}

enum NetworkServiceSpyMessages {
  case returnWantedError
  case success
  case withParseError
  case withLoadJSONError
}
