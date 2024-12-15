//
//  LoginViewModel.swift
//  Psotify
//
//  Created by Turan, Kaan on 15.11.2024.
//

import Foundation

final class LoginViewModel: ObservableObject {
    private let authUseCase: AuthUseCaseProtocol
    
    init(authUseCase: AuthUseCaseProtocol = AppDIContainer.shared.resolve(AuthUseCaseProtocol.self)) {
        self.authUseCase = authUseCase
    }
}

// MARK: Helper Funcs
extension LoginViewModel {
    func getSpotifyAuthURL() -> URL? {
        PsotifyEndpoint.authCode.request?.url
    }
    
    func handleLogin(with url: URL) async {
        guard let code = self.extractCode(from: url) else { return }
        do {
           try await authUseCase.logIn(with: code)
        } catch {
            print(error)
        }
    }
    
    private func extractCode(from url: URL) -> String? {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        return components?.queryItems?.first(where: { $0.name == "code" })?.value
    }
}
