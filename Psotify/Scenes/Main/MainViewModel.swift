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
    let authUseCase: AuthUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
        self.authUseCase = AuthUseCase(networkService: networkService)
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
}

//MARK: ViewModels
extension MainViewModel {
  var loginViewModel: LoginViewModel {
        LoginViewModel(authUseCase: self.authUseCase)
    }

  var tabbarViewModel: TabbarViewModel {
    return TabbarViewModel(networkService: self.networkService)
  }
}
