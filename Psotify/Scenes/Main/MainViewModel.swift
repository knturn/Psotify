//
//  MainViewModel.swift
//  Psotify
//
//  Created by Turan, Kaan on 15.11.2024.
//

import Combine
import Foundation

final class MainViewModel: ObservableObject {

  private let authUseCase: AuthUseCaseProtocol

  @Published var loginState: UserLoginState = .inProgress
  private var cancellables = Set<AnyCancellable>()

  init(authUseCase: AuthUseCaseProtocol = AppDIContainer.shared.resolve(AuthUseCaseProtocol.self)) {
    self.authUseCase = authUseCase
    observeLoginState()
  }

  private func observeLoginState() {
    authUseCase.loginPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] loginState in
        self?.loginState = loginState
      }
      .store(in: &cancellables)
  }

  func checkLoginState() async {
    do {
      try await authUseCase.checkLoginState()
    } catch {
      print(error.localizedDescription)
    }
  }
}
