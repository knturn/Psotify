//
//  XCTestCase+Extension.swift
//  PsotifyTests
//
//  Created by Turan, Kaan on 6.12.2024.
//

import XCTest

extension XCTestCase {
  func XCTAssertThrowsErrorAsync<T>(
      _ expression: @autoclosure @escaping () async throws -> T,
      _ message: @autoclosure () -> String = "",
      file: StaticString = #filePath,
      line: UInt = #line,
      _ errorHandler: (Error) -> Void
  ) async {
      do {
          _ = try await expression()
          XCTFail("Expected to throw an error but succeeded. \(message())", file: file, line: line)
      } catch {
          errorHandler(error)
      }
  }
}

