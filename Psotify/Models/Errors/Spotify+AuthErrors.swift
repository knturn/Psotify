//
//  Spotify+AuthErrors.swift
//  Psotify
//
//  Created by Turan, Kaan on 15.11.2024.
//

import Foundation

protocol AppError: Error {
    var localizedDescription: String { get }
}

// MARK: SpotifyAuthError
enum SpotifyAuthError: AppError {
    case invalidClientID
    case invalidClientSecret
    case invalidAuthCode
    case invalidRedirectURI
    case tokenUnavailable
    case tokenFetchError(Error)
    case networkError(Error)
    case serverError(statusCode: Int, message: String)
    case refreshTokenExpired
    case invalidRequest(message: String)

    var localizedDescription: String {
        switch self {
        case .invalidClientID:
            return "Invalid Client ID. Please check your configuration."
        case .invalidClientSecret:
            return "Invalid Client Secret. Please verify your credentials."
        case .invalidAuthCode:
            return "The authorization code is invalid or expired. Please log in again."
        case .invalidRedirectURI:
            return "The redirect URI is not configured correctly."
        case .tokenUnavailable:
            return "Access token is unavailable. Please log in again."
        case .tokenFetchError(let error):
            return "Failed to fetch token: \(error.localizedDescription). Please retry the login process."
        case .networkError(let error):
            return "A network error occurred: \(error.localizedDescription). Please check your connection and try again."
        case .serverError(let statusCode, let message):
            return "Server error \(statusCode): \(message). Please contact support if the issue persists."
        case .refreshTokenExpired:
            return "The refresh token has expired. Please reauthenticate."
        case .invalidRequest(let message):
            return "Invalid request: \(message). Please verify the request parameters and try again."
        }
    }
}
