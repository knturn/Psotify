//
//  LoginViewModel.swift
//  Psotify
//
//  Created by Turan, Kaan on 15.11.2024.
//

import Foundation

final class LoginViewModel: ObservableObject {
   
}

// MARK: Helper Funcs
extension LoginViewModel {
    func getSpotifyAuthURL() -> URL? {
        PsotifyEndpoint.authCode.request?.url
    }

    func handleLogin(with url: URL) {
        guard let codeData = self.extractCode(from: url)?.toData() else { return }
        do {
            try KeyChainManager.save(key: KeyChainManager.authCode, data: codeData)
        } catch {
         print(error)
        }
    }

    private func extractCode(from url: URL) -> String? {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        return components?.queryItems?.first(where: { $0.name == "code" })?.value
    }
}
