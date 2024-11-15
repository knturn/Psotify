//
//  NetworkServiceErrors.swift
//  Psotify
//
//  Created by Turan, Kaan on 15.11.2024.
//

import Foundation

enum NetworkServiceErrors: Error {
    case httpError(status: HTTPStatus?, data: Data? = nil)
    case fetchFailed
    case fetchedButEmtpy
    case parseFailed
    case URLError
    case requestError
    var message: String? {
        switch self {
        case .httpError(_, let data):
            guard let data = data else { return nil }
            let response = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            return response?.message
        case .fetchFailed:
            return "fetchFailed"
        case .fetchedButEmtpy:
            return "fetchedEmptyResult"
        case .parseFailed:
            return "parseFailed"
        case .URLError:
            return "URLError"
        case .requestError:
            return "movieDBResponseError"
        }
    }
}
