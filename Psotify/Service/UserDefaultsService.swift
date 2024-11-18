//
//  UserDefaultsService.swift
//  Psotify
//
//  Created by Turan, Kaan on 17.11.2024.
//

import Foundation

protocol UserDefaultsServiceProtocol {
    static func saveElement(defaults: UserDefaults, model: Encodable, forKey key: String) async throws
    static func removeElement(defaults: UserDefaults, forKey key: String)
    static func getElement<T: Codable>(defaults: UserDefaults, forKey key: String, type: T.Type) -> T?
}

final class UserDefaultsService {
}

extension UserDefaultsService: UserDefaultsServiceProtocol {
    static func saveElement(defaults: UserDefaults = .standard, model: Encodable, forKey key: String) async throws {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(model)
            defaults.set(data, forKey: key)
        } catch {
            throw UserDefaultsError.saveError
        }
    }
    
    static func removeElement(defaults: UserDefaults = .standard, forKey key: String) {
        defaults.removeObject(forKey: key)
    }
    
    static func getElement<T: Codable>(defaults: UserDefaults = .standard, forKey key: String, type: T.Type) -> T? {
        guard let data = defaults.data(forKey: key) else {
            return nil
        }
        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from: data)
    }
}

extension UserDefaultsService {
    enum UserDefaultsError: Error {
        case unknown
        case saveError
    }
}
