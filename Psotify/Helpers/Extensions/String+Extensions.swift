//
//  String+Extensions.swift
//  Psotify
//
//  Created by Turan, Kaan on 15.11.2024.
//

import Foundation

extension String {
    func toData() -> Data? {
        return data(using: .utf8)
    }
}
