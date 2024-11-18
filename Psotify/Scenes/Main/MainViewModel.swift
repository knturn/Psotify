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
    
    init(authUseCase: AuthUseCaseProtocol = AuthUseCase.shared) {
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
}


enum UserState {
    case login
    case logout
    case inProgress
}
