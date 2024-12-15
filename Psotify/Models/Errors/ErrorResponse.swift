//
//  ErrorResponse.swift
//  Psotify
//
//  Created by Turan, Kaan on 15.11.2024.
//

import Foundation

class ErrorResponse: Decodable {
    var success: Bool?
    var code: Int?
    var message: String?

    enum CodingKeys: String, CodingKey {
        case success
        case code = "status_code"
        case message = "status_message"
    }
}
