//
//  PsotifyApp.swift
//  Psotify
//
//  Created by Turan, Kaan on 15.11.2024.
//

import SwiftUI

@main
struct PsotifyApp: App {
    private let diContainer = AppDIContainer.shared

  init() {
    setupDIContainer()
  }
    var body: some Scene {
        WindowGroup {
          MainView()
                .preferredColorScheme(.dark)
                .environmentObject(diContainer.makeNavigation())
        }
    }


  func setupDIContainer(){
    let netwokService = NetworkService()

    diContainer.bind(service: AuthUseCaseProtocol.self) { authUseCase in
      return AuthUseCase(networkService: netwokService)
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
