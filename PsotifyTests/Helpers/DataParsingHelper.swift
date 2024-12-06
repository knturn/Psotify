//
//  DataParsingHelper.swift
//  PsotifyTests
//
//  Created by Turan, Kaan on 5.12.2024.
//

import Foundation
import XCTest

final class DataParsingHelper {
    static func loadJSON(from fileName: String, in bundle: Bundle) -> Data? {
        guard let url = bundle.url(forResource: fileName, withExtension: nil) else {
            return nil
        }
      let data = try? Data(contentsOf: url)
      return data
    }

    static func parseData<T: Decodable>(data: Data) -> T? {
        do {
            let response = try JSONDecoder().decode(T.self, from: data)
            return response
        } catch {
            print("Failed to decode JSON: \(error)")
            return nil
        }
    }
}
