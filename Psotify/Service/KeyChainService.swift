//
//  KeyChainService.swift
//  Psotify
//
//  Created by Turan, Kaan on 15.11.2024.
//

import Security
import Foundation
protocol KeyChainServiceProtocol {
    func save(key: String, data: Data) throws
    func get(key: String) -> Data?
    func remove(key: String)
}

class KeyChainService: KeyChainServiceProtocol {
    func save(key: String, data: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {throw KeyChainError.unknown(status)}
    }
    
     func remove(key: String) {
        let query = [kSecClass as String: kSecClassGenericPassword,
                     kSecAttrAccount as String: key] as [String: Any]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status != errSecItemNotFound else {
            print("Item not found in keychain")
            return
        }
        guard status == errSecSuccess else {
            print("An error occured while removing keychain item: \(status)")
            return}
    }
    
     func get(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        if status == noErr {
            return dataTypeRef as? Data ?? nil
        } else {
            return nil
        }
    }
}

extension KeyChainService {
    enum KeyChainError: Error {
        case unknown(OSStatus)
    }
}
