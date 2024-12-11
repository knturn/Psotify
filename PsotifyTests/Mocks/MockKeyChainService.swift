//
//  MockKeyChainService.swift
//  PsotifyTests
//
//  Created by Turan, Kaan on 6.12.2024.
//

import Foundation
@testable import Psotify

final class MockKeyChainService: KeyChainServiceProtocol {
    var savedData: [String: Data] = [:]

    func save(key: String, data: Data) throws {
        savedData[key] = data
    }

    func get(key: String) -> Data? {
        savedData[key]
    }

    func remove(key: String) {
        savedData[key] = nil
    }
}

final class MockUserDefaultsService: UserDefaultsServiceProtocol {
    private var storage: [String: Data] = [:]

    func saveElement(defaults: UserDefaults = .standard, model: Encodable, forKey key: String) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(model)
        storage[key] = data
    }

    func removeElement(defaults: UserDefaults = .standard, forKey key: String) {
        storage.removeValue(forKey: key)
    }

    func getElement<T: Codable>(defaults: UserDefaults = .standard, forKey key: String, type: T.Type) -> T? {
        guard let data = storage[key] else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from: data)
    }
}
