//
//  MockNetworkService.swift
//  PsotifyTests
//
//  Created by Turan, Kaan on 6.12.2024.
//

import Foundation
@testable import Psotify

final class MockNetworkService<ResponseType: Decodable>: NetworkServiceProtocol {
    var mockData: Data?
    var mockError: Error?
    var shouldReturnError = false

    init(mockData: Data? = nil, mockError: Error? = nil, shouldReturnError: Bool = false) {
        self.mockData = mockData
        self.mockError = mockError
        self.shouldReturnError = shouldReturnError
    }

    func fetch<Response: Decodable>(request: URLRequest) async throws -> Response {
        if shouldReturnError {
            if let error = mockError {
                throw error
            }
            throw NSError(domain: "MockError", code: -1, userInfo: nil)
        }

        if let data = mockData {
            let decoder = JSONDecoder()
            return try decoder.decode(Response.self, from: data)
        }

        throw NSError(domain: "MockError", code: -1, userInfo: nil)
    }
}



