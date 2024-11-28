//
//  TabbarViewModel.swift
//  Psotify
//
//  Created by Turan, Kaan on 27.11.2024.
//

import Foundation

class TabbarViewModel: ObservableObject {
  // MARK: UseCases
  private let getProfileUseCase: GetUserProfileUseCaseProtocol
  private let getAlbumsUseCase: GetAlbumsUseCaseProtocol
  private let getPLaylistsUseCase: GetPlaylistsUseCaseProtocol

  init(networkService: NetworkServiceProtocol) {
    self.getProfileUseCase = GetUserProfileUseCase(networkService: networkService)
    self.getAlbumsUseCase = GetAlbumsUseCase(networkService: networkService)
    self.getPLaylistsUseCase = GetPlaylistsUseCase(networkService: networkService)
  }
}

extension TabbarViewModel {
  var homeViewModel: HomeViewModel {
    return .init(getUserProfileUseCase: self.getProfileUseCase, getAlbumsUseCase: self.getAlbumsUseCase, getPlaylistUseCase: self.getPLaylistsUseCase)
  }
}
