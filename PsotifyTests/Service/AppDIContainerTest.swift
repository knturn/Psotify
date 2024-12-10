//
//  AppDIContainerTest.swift
//  PsotifyTests
//
//  Created by Turan, Kaan on 6.12.2024.
//

import XCTest
@testable import Psotify

// Mock Services
protocol MockServiceProtocol {}
class MockService: MockServiceProtocol {}

class AppDIContainerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        AppDIContainer.resetForTesting()
    }

    override func tearDown() {
        AppDIContainer.resetForTesting()
        super.tearDown()
    }

    // MARK: - Singleton Instance Test

    func testSingletonInstance() {
        // Given: AppDIContainer is set up
        let sutContainer = AppDIContainer.shared

        // When: We access the shared instance twice
        let instance1 = sutContainer
        let instance2 = sutContainer

        // Then: Both instances should be the same
        XCTAssertTrue(instance1 === instance2, "AppDIContainer.shared should always return the same instance.")
    }

    // MARK: - Bind and Resolve Singleton Service Test

    func testBindAndResolveSingletonService() {
        // Given: A container that binds MockService as a singleton
        let sutContainer = AppDIContainer.shared
        sutContainer.bind(service: MockServiceProtocol.self, .singleton) { _ in MockService() }

        // When: Resolving the service twice
        let resolved1: MockServiceProtocol = sutContainer.resolve(MockServiceProtocol.self)
        let resolved2: MockServiceProtocol = sutContainer.resolve(MockServiceProtocol.self)

        // Then: Both resolutions should return the same instance
        XCTAssertTrue(resolved1 as AnyObject === resolved2 as AnyObject, "Singleton services should return the same instance.")
    }

    // MARK: - Bind and Resolve Transient Service Test

    func testBindAndResolveTransientService() {
        // Given: A container that binds MockService as a transient service
        let sutContainer = AppDIContainer.shared
        sutContainer.bind(service: MockServiceProtocol.self, .transient) { _ in MockService() }

        // When: Resolving the service twice
        let resolved1: MockServiceProtocol = sutContainer.resolve(MockServiceProtocol.self)
        let resolved2: MockServiceProtocol = sutContainer.resolve(MockServiceProtocol.self)

        // Then: Both resolutions should return same instances because MockService is class so when you want to resolve service, It should give you same instance until die
        XCTAssertTrue(resolved1 as AnyObject === resolved2 as AnyObject, "Transient services should return the same instance.")
    }
}
