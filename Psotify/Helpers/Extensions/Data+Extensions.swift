//
//  Data+Extensions.swift
//  Psotify
//
//  Created by Turan, Kaan on 15.11.2024.
//

import Foundation

extension Data {
    func toString() -> String? {
        let result = String(decoding: self, as: UTF8.self)
        return result
     }
}
