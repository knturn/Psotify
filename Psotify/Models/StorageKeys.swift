//
//  StorageKeys.swift
//  Psotify
//
//  Created by Turan, Kaan on 26.11.2024.
//

import Foundation
enum UserDefaultsServiceKeys: String {
  case tokenStorage = "userAccessInfo"
}

enum KeychainServiceKeys: String {
  case authCode = "authCode"
}
