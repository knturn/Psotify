//
//  ConfigurationSettings.swift
//  Psotify
//
//  Created by Turan, Kaan on 19.11.2024.
//

import Foundation

final class Configuration: AppConfigurationProtocol {
    enum Constants {
        static let httpsPrefix = "https://"
    }
    static var clientID: String {
        let url: String? = try? self.value(for: "CLIENT_ID")
        return url ?? ""
    }
    
    static var clientSecret: String {
        let scheme: String? = try? self.value(for: "CLIENT_SECRET")
        return scheme ?? ""
    }
    
    //Base 64 encoded string that contains the client ID and client secret key.
    static var authorization: String? {
        let credentials = "\(String(describing: self.clientID)):\(String(describing: self.clientSecret))"
        guard let data = credentials.data(using: .utf8) else {
            return nil
        }
        return "Basic \(data.base64EncodedString())"
    }
    
    static var redirectURI: String {
        let key: String? = try? self.value(for: "Redirect_URL")
        return Constants.httpsPrefix + (key ?? "")
    }
    
    static var authBaseURL: URL? {
        guard let authURL: String = try? self.value(for: "AUTH_BASE_URL"),
              let url = URL(string: Constants.httpsPrefix + authURL) else { return nil }
        return url
    }
    
    static var apiBaseURL: URL? {
        guard let apiBaseURL: String = try? self.value(for:  "API_BASE_URL"),
              let url = URL(string: Constants.httpsPrefix + apiBaseURL) else { return nil }
        return url
    }
}

extension Configuration {
    static func validate() throws {
        guard !clientID.isEmpty else {
            throw ConfigurationError.missingValue("CLIENT_ID is missing or empty.")
        }
        guard !clientSecret.isEmpty else {
            throw ConfigurationError.missingValue("CLIENT_SECRET is missing or empty.")
        }
        guard authBaseURL != nil else {
            throw ConfigurationError.missingValue("AUTH_BASE_URL is missing or invalid.")
        }
        guard apiBaseURL != nil else {
            throw ConfigurationError.missingValue("API_BASE_URL is missing or invalid.")
        }
    }

  enum ConfigurationError: Error {
        case missingValue(String)
    }
}
