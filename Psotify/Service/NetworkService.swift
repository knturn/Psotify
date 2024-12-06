//
//  NetworkService.swift
//  Psotify
//
//  Created by Turan, Kaan on 15.11.2024.
//

import Foundation
protocol NetworkServiceProtocol {
    func fetch<T: Decodable>(request: URLRequest) async throws -> T where T: Decodable
}

protocol NetworkSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkSession {}

final class NetworkService: NetworkServiceProtocol {
    private let session: NetworkSession
    
    init(session: NetworkSession = URLSession.shared) {
        self.session = session
    }
    
    func fetch<T: Decodable>(request: URLRequest) async throws -> T {
        let (data, response) = try await fetchData(for: request)
        try validateResponse(response, data: data)
        return try decodeData(data, to: T.self)
    }
}

// MARK: - Helper Methods
private extension NetworkService {
    func fetchData(for request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch _ as URLError {
            throw NetworkServiceErrors.URLError
        } catch {
            throw NetworkServiceErrors.fetchFailed
        }
    }

    func validateResponse(_ response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw NetworkServiceErrors.httpError(
                status: HTTPStatus(rawValue: statusCode),
                data: data
            )
        }
    }

  func decodeData<T: Decodable>(_ data: Data, to type: T.Type) throws -> T {
      do {
          return try JSONDecoder().decode(T.self, from: data)
      } catch {
        throw  data.isEmpty ? NetworkServiceErrors.fetchedButEmtpy : NetworkServiceErrors.parseFailed
      }
  }
}
