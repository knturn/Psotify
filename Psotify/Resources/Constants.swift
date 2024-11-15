//
//  Constants.swift
//  Psotify
//
//  Created by Turan, Kaan on 15.11.2024.
//

import Foundation
struct Constants {
    static let designer = "Knturn"
    static let authBaseURL = Bundle.main.object(forInfoDictionaryKey: "AuthBaseURL") as? String
    static let apiBaseURL = Bundle.main.object(forInfoDictionaryKey: "APIBaseURL") as? String
    static let clientID = Bundle.main.object(forInfoDictionaryKey: "ClientID") as? String
    static let clientSecret = Bundle.main.object(forInfoDictionaryKey: "ClientSecret") as? String
    static let redirectURI = Bundle.main.object(forInfoDictionaryKey: "RedirectURL") as? String
    static let scope = "user-read-private user-read-email"
    static let authState = "TRUE"
}
