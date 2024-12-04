//
//  AppDIContainer.swift
//  Psotify
//
//  Created by Turan, Kaan on 1.12.2024.
//

import Foundation
enum Lifetime {
    case singleton
    case transient
}

protocol AppDIContainerProtocol {
    func bind<Service>(service: Service.Type, _ lifetime: Lifetime, resolver: @escaping (AppDIContainerProtocol) -> Service)
    func resolve<Service>(_ type: Service.Type) -> Service
    func makeNavigation() -> Navigation
}

final class AppDIContainer: AppDIContainerProtocol {
    static let shared: AppDIContainerProtocol = AppDIContainer()

    private var services: [String: ResolverWrapper] = [:]
    private var singletons: [String: Any] = [:]

    private init() {}

    func bind<Service>(
        service: Service.Type,
        _ lifetime: Lifetime,
        resolver: @escaping (AppDIContainerProtocol) -> Service
    ) {
        let key = String(describing: service)
        services[key] = ResolverWrapper(lifetime: lifetime, resolve: resolver)
    }

  func resolve<Service>(_ type: Service.Type) -> Service {
      let key = String(describing: Service.self)
      guard let wrapper = services[key] else {
          fatalError("Service dependency injection error: \(key) is not registered.")
      }

      switch wrapper.lifetime {
      case .singleton:
          if let instance = singletons[key] as? Service {
              return instance
          }
          guard let instance = wrapper.resolve(self) as? Service else {
              fatalError("Service dependency injection error: Failed to resolve \(key).")
          }
          singletons[key] = instance
          return instance

      case .transient:
          guard let instance = wrapper.resolve(self) as? Service else {
              fatalError("Service dependency injection error: Failed to resolve \(key).")
          }
          return instance
      }
  }

  func makeNavigation() -> Navigation {
      return Navigation()
  }
}

// MARK: - Resolver Wrapper
private struct ResolverWrapper {
    let lifetime: Lifetime
    let resolve: (AppDIContainerProtocol) -> Any
}
