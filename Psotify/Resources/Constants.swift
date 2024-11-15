//
//  Constants.swift
//  Psotify
//
//  Created by Turan, Kaan on 15.11.2024.
//

import Foundation
struct Constants {
    static let designer = "Knturn"
    static let authBaseURL = Bundle.main.object(forInfoDictionaryKey: "AUTH_BASE_URL") as? String
    static let apiBaseURL = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String
    static let clientID = Bundle.main.object(forInfoDictionaryKey: "CLIENT_ID") as? String
    static let clientSecret = Bundle.main.object(forInfoDictionaryKey: "CLIENT_SECRET") as? String
    static let redirectURI = Bundle.main.object(forInfoDictionaryKey: "Redirect_URL") as? String
    static let scope = "user-read-private user-read-email"
    static let authState = "TRUE"
}
