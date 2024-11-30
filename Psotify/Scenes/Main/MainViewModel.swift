//
//  MainViewModel.swift
//  Psotify
//
//  Created by Turan, Kaan on 15.11.2024.
//

import Combine
import Foundation

final class MainViewModel: ObservableObject {
  @Published var loginState: UserLoginState
  private let authUseCase: AuthUseCaseProtocol
  private var cancellables = Set<AnyCancellable>()
  
  @Published var screenState: ScreenState = .isLoading

  init(authUseCase: AuthUseCaseProtocol = AuthUseCase.shared, loginState: UserLoginState = .inProgress) {
    self.authUseCase = authUseCase
    self.loginState = loginState
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
      DispatchQueue.main.async { [weak self] in
        self?.screenState = .loaded
      }
    } catch {
      print(error.localizedDescription)
      DispatchQueue.main.async { [weak self] in
        self?.loginState = .logout
      }
    }
  }
}
