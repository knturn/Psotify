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

    diContainer.bind(service: AuthUseCaseProtocol.self, .singleton) { authUseCase in
      let netwokService = diContainer.resolve(NetworkServiceProtocol.self)
      return AuthUseCase(networkService: netwokService)
    }

    diContainer.bind(service: GetSongUseCaseProtocol.self, .transient) { songUseCase in
      let netwokService = diContainer.resolve(NetworkServiceProtocol.self)
      return GetSongUseCase(networkService: netwokService)
    }
    diContainer.bind(service: GetUserProfileUseCaseProtocol.self, .transient) { profileUseCase in
      let netwokService = diContainer.resolve(NetworkServiceProtocol.self)
      return GetUserProfileUseCase(networkService: netwokService)
    }
    diContainer.bind(service: GetAlbumsUseCaseProtocol.self, .transient) { albumUseCase in
      let netwokService = diContainer.resolve(NetworkServiceProtocol.self)
      return GetAlbumsUseCase(networkService: netwokService)
    }

    diContainer.bind(service: GetPlaylistsUseCaseProtocol.self, .transient) { playlistUseCase in
      let netwokService = diContainer.resolve(NetworkServiceProtocol.self)
      return GetPlaylistsUseCase(networkService: netwokService)
    }

    diContainer.bind(service: GetSearchResultProtocol.self, .transient) { searchResultUseCase in
      let netwokService = diContainer.resolve(NetworkServiceProtocol.self)
      return GetSearchResultUseCase(networkService: netwokService)
    }

    diContainer.bind(service: GetUserSavedTracksUseCaseProtocol.self, .transient) { getUserSavedTracksUseCase in
      let netwokService = diContainer.resolve(NetworkServiceProtocol.self)
      return GetUserSavedTracksUseCase(networkService: netwokService)
    }
  }
}
