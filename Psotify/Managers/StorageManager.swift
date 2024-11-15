//
//  StorageManager.swift
//  Psotify
//
//  Created by Turan, Kaan on 15.11.2024.
//

import Foundation

protocol StorageManagerAccountProvider {
    func saveTokenModel(_ model: PsotifyTokenStorageModel) async throws
    func removeTokenModel()
    func isTokenExpired() -> Bool
    func getRefreshToken() -> String?
    func getTokenModel() -> PsotifyTokenStorageModel?
}

final class StorageManager {
    private let userDefaults = UserDefaults.standard
}

extension StorageManager: StorageManagerAccountProvider {
    func saveTokenModel(_ model: PsotifyTokenStorageModel) async throws {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(model)
            userDefaults.set(data, forKey: Constants.localStorageTokenModelKey)
        } catch {
            throw SpotifyAuthError.invalidClientID
        }
    }
    
    func removeTokenModel() {
        userDefaults.removeObject(forKey: Constants.localStorageTokenModelKey)
    }
    
    func getTokenModel() -> PsotifyTokenStorageModel? {
        var tokenModel: PsotifyTokenStorageModel?
        guard let data = UserDefaults.standard.data(forKey: Constants.localStorageTokenModelKey) else {return nil}
        let decoder = JSONDecoder()
        tokenModel = try? decoder.decode(PsotifyTokenStorageModel.self, from: data)
        return tokenModel
    }
    
    func isTokenExpired() -> Bool {
        guard let tokenModel = self.getTokenModel(),
              tokenModel.refreshToken != nil else { return true }
        return Date() >= tokenModel.expireDate
    }
    
    func getRefreshToken() -> String? {
        guard let tokenModel = self.getTokenModel() else { return nil }
        return tokenModel.refreshToken
    }
}

