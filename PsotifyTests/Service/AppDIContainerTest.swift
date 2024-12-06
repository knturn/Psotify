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

        // Then: Both resolutions should return different instances
        XCTAssertFalse(resolved1 as AnyObject === resolved2 as AnyObject, "Transient services should return new instances.")
    }

    // MARK: - Fatal Testing (Unregistered Service Resolution)
   // When this case happen app terminated with fatal error. There for this func is in comment lines. Try comment out and tested for fatal error.
//    func testUnregisteredServiceResolutionFails() {
//        // Given: A container with no registered service for MockServiceProtocol
//        let sutContainer = AppDIContainer.shared
//
//        // When: Attempting to resolve an unregistered service
//
//        // Then: A fatalError should be triggered
//        sutContainer.bind(service: MockServiceProtocol.self, .singleton) { _ in MockService() }
//
//        // Use the XCTest framework's mechanism to check fatalError
//        XCTAssertThrowsError({
//            sutContainer.resolve(MockServiceProtocol.self)
//        }(), "Resolving an unregistered service should trigger fatalError.")
//
//
//    }
}
