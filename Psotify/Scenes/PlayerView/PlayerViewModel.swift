//
//  PlayerViewModel.swift
//  Psotify
//
//  Created by Turan, Kaan on 29.11.2024.
//

import SwiftUI

class PlayerViewModel: ObservableObject {
    @Published var song: SongResponse?
    @Published var totalTime: TimeInterval = 0.0
    @Published var currentTime: TimeInterval = 0.0

    private let playerManager: PlayerManager
    private let getSongUseCase: GetSongUseCaseProtocol
    private let id: String

    init(
        getSongUseCase: GetSongUseCaseProtocol = AppDIContainer.shared.resolve(GetSongUseCaseProtocol.self),
        id: String,
        playerManager: PlayerManager = .shared
    ) {
        self.getSongUseCase = getSongUseCase
        self.id = id
        self.playerManager = playerManager
    }

  @MainActor
    func fetchSong() {
        Task { [weak self] in
            guard let self else { return }
            do {
                let songModel = try await getSongUseCase.fetchSong(with: id)
                  self.song = songModel
                  self.setupAudio()
            } catch {
                print("Şarkı bilgilerine erişilemedi")
            }
        }
    }

    func setupAudio() {
        if let urlStr = song?.previewURL {
            playerManager.setContentOf(urlStr: urlStr)
        } else if let url = Bundle.main.url(forResource: "piano", withExtension: "mp3") {
            playerManager.setContentOf(urlStr: url.absoluteString)
        }
        totalTime = playerManager.getTotalTime()
    }
  
  @MainActor
    func updateCurrentTime() {
      self.currentTime = playerManager.getCurrentTime()
    }

    func timeString(for time: TimeInterval) -> String {
        let minute = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minute, seconds)
    }
}

// MARK: For navigation process
extension PlayerViewModel: Equatable, Hashable {
    static func == (lhs: PlayerViewModel, rhs: PlayerViewModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
