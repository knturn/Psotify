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
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                throw NetworkServiceErrors.httpError(
                    status: HTTPStatus(rawValue: (response as? HTTPURLResponse)?.statusCode ?? -1),
                    data: data
                )
            }
            
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw NetworkServiceErrors.parseFailed
            }
        } catch let error as URLError {
            throw NetworkServiceErrors.URLError
        } catch {
            throw NetworkServiceErrors.fetchFailed
        }
    }
}
