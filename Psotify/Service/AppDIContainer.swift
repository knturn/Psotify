//
//  AppDIContainer.swift
//  Psotify
//
//  Created by Turan, Kaan on 1.12.2024.
//

import Foundation

protocol AppDICProtocol {
  func bind<Service>(service: Service.Type, resolver: @escaping (AppDIContainer) -> Service)
  func resolve<Service>(_ type: Service.Type) -> Service
  func makeNavigation() -> Navigation
}

final class AppDIContainer: AppDICProtocol {
  static let shared: AppDICProtocol = AppDIContainer()
  private var services: [String: Any] = [:]

  private init(){}

  func bind<Service>(service: Service.Type, resolver: @escaping (AppDIContainer) -> Service) {
    let key = String(describing: Service.self)
    self.services[key] = resolver(self)
  }

  func resolve<Service>(_ type: Service.Type) -> Service {
    let key = String(describing: Service.self)
    guard let service = services[key] as? Service else {
      fatalError("kapat git")
    }
    return service
  }

    func makeNavigation() -> Navigation {
        return Navigation()
    }
}

