//
//  MainViewModel.swift
//  Psotify
//
//  Created by Turan, Kaan on 15.11.2024.
//

import Combine
import Foundation

final class MainViewModel: ObservableObject {
  //MARK: USE CASES
  private let authUseCase: AuthUseCaseProtocol
  private let getProfileUseCase: GetUserProfileUseCaseProtocol
  private let getAlbumsUseCase: GetAlbumsUseCaseProtocol
  private let getPLaylistsUseCase: GetPlaylistsUseCaseProtocol
  private let getSongUseCase: GetSongUseCaseProtocol

  @Published var loginState: UserLoginState = .inProgress
  private var cancellables = Set<AnyCancellable>()

  init(getProfileUseCase: GetUserProfileUseCaseProtocol = AppDIContainer.shared.resolve(GetUserProfileUseCaseProtocol.self),
       getAlbumsUseCase: GetAlbumsUseCaseProtocol = AppDIContainer.shared.resolve(GetAlbumsUseCaseProtocol.self),
       getPLaylistsUseCase: GetPlaylistsUseCaseProtocol = AppDIContainer.shared.resolve(GetPlaylistsUseCaseProtocol.self),
       getSongUseCase: GetSongUseCaseProtocol = AppDIContainer.shared.resolve(GetSongUseCaseProtocol.self),
       authUseCase: AuthUseCaseProtocol = AppDIContainer.shared.resolve(AuthUseCaseProtocol.self)) {
    self.authUseCase = authUseCase
    self.getProfileUseCase = getProfileUseCase
    self.getAlbumsUseCase = getAlbumsUseCase
    self.getPLaylistsUseCase = getPLaylistsUseCase
    self.getSongUseCase = getSongUseCase
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
        self?.loginState = .login
      }
    } catch {
      print(error.localizedDescription)
      DispatchQueue.main.async { [weak self] in
        self?.loginState = .logout
      }
    }
  }
}
