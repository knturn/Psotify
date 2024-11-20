//
//  ConfigurationProtocol.swift
//  Psotify
//
//  Created by Turan, Kaan on 19.11.2024.
//

import Foundation

protocol AppConfigurationProtocol {}

extension AppConfigurationProtocol {
    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
            throw AppConfigurationError.missingKey
        }

        switch object {
            case let value as T:
                return value
            case let string as String:
                guard let value = T(string) else { fallthrough }
                return value
            default:
                throw AppConfigurationError.invalidValue
        }
    }
}

enum AppConfigurationError: Swift.Error {
    case missingKey, invalidValue
}
