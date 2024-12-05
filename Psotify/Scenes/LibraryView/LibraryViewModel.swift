//
//  LibraryViewModel.swift
//  Psotify
//
//  Created by Turan, Kaan on 3.12.2024.
//

import SwiftUI

class LibraryViewModel: ObservableObject {
    private let getUserTopTracksUseCase: GetUserTopTracksUseCaseProtocol
    @Published var tracks: UserTracksResponse?
    @Published var screenState: ScreenState = .isLoading

    init(getUserTopTracksUseCase: GetUserTopTracksUseCaseProtocol = AppDIContainer.shared.resolve(GetUserTopTracksUseCaseProtocol.self)) {
        self.getUserTopTracksUseCase = getUserTopTracksUseCase
    }

    @MainActor
    func fetch() {
      screenState = .isLoading
        Task { [weak self] in
            guard let self else { return }
            do {
                let model = try await self.getUserTopTracksUseCase.fetchTopTracks()
                self.tracks = model
                    self.screenState = .loaded
            } catch {
                self.screenState = .error("Failed to load tracks")
            }
        }
    }
}
