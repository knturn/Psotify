//
//  PsotifyApp+Extension.swift
//  Psotify
//
//  Created by Turan, Kaan on 1.12.2024.
//

import Foundation

extension PsotifyApp {
  // Service Dependency Injection with DI container

  func setupDIContainer(with diContainer: AppDIContainerProtocol){
    diContainer.bind(service: NetworkServiceProtocol.self) { networkService in
      NetworkService()
    }

    let netwokService = diContainer.resolve(NetworkServiceProtocol.self)

    diContainer.bind(service: AuthUseCaseProtocol.self) { authUseCase in
      AuthUseCase(networkService: netwokService)
    }

    diContainer.bind(service: GetSongUseCaseProtocol.self) { songUseCase in
      GetSongUseCase(networkService: netwokService)
    }
    diContainer.bind(service: GetUserProfileUseCaseProtocol.self) { profileUseCase in
      GetUserProfileUseCase(networkService: netwokService)
    }
    diContainer.bind(service: GetAlbumsUseCaseProtocol.self) { albumUseCase in
      GetAlbumsUseCase(networkService: netwokService)
    }

    diContainer.bind(service: GetPlaylistsUseCaseProtocol.self) { playlistUseCase in
      GetPlaylistsUseCase(networkService: netwokService)
    }

  }
}
