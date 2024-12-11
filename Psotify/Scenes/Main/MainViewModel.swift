//
//  MainViewModel.swift
//  Psotify
//
//  Created by Turan, Kaan on 15.11.2024.
//

import Combine
import Foundation

final class MainViewModel: ObservableObject {
  @Published var loginState: UserLoginState = .inProgress

  private let authUseCase: AuthUseCaseProtocol
  private var cancellables = Set<AnyCancellable>()

  init(authUseCase: AuthUseCaseProtocol = AppDIContainer.shared.resolve(AuthUseCaseProtocol.self)) {
    self.authUseCase = authUseCase
    observeLoginState()
  }

  func refreshLoginState() {
    Task { [weak self] in
      guard let self else { return }
      do {
        try await authUseCase.refreshLoginState()
      } catch {
        print(error.localizedDescription)
      }
    }
  }

  private func observeLoginState() {
    authUseCase.loginPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] loginState in
        self?.loginState = loginState
      }
      .store(in: &cancellables)
  }
}
