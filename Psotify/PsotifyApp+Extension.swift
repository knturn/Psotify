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
    diContainer.bind(service: KeyChainServiceProtocol.self, .transient) { keychainService in
      KeyChainService()
    }

    diContainer.bind(service: NetworkServiceProtocol.self, .transient) { networkService in
      NetworkService()
    }

    let netwokService = diContainer.resolve(NetworkServiceProtocol.self)

    diContainer.bind(service: AuthUseCaseProtocol.self, .singleton) { authUseCase in
      AuthUseCase(networkService: netwokService)
    }

    diContainer.bind(service: GetSongUseCaseProtocol.self, .transient) { songUseCase in
      GetSongUseCase(networkService: netwokService)
    }
    diContainer.bind(service: GetUserProfileUseCaseProtocol.self, .transient) { profileUseCase in
      GetUserProfileUseCase(networkService: netwokService)
    }
    diContainer.bind(service: GetAlbumsUseCaseProtocol.self, .transient) { albumUseCase in
      GetAlbumsUseCase(networkService: netwokService)
    }

    diContainer.bind(service: GetPlaylistsUseCaseProtocol.self, .transient) { playlistUseCase in
      GetPlaylistsUseCase(networkService: netwokService)
    }

    diContainer.bind(service: GetSearchResultProtocol.self, .transient) { searchResultUseCase in
      GetSearchResultUseCase(networkService: netwokService)
    }

    diContainer.bind(service: GetUserSavedTracksUseCaseProtocol.self, .transient) { getUserSavedTracksUseCase in
      GetUserSavedTracksUseCase(networkService: netwokService)
    }
  }
}
