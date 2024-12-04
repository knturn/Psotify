//
//  PlayerManager.swift
//  Psotify
//
//  Created by Turan, Kaan on 29.11.2024.
//

import Foundation
import Combine
import AVFoundation

class PlayerManager: ObservableObject {
    static let shared = PlayerManager()
    private var player: AVAudioPlayer?

    @Published var isPlaying: Bool = false

    private init() {}

    func playSong() {
        player?.play()
        isPlaying = true
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func close() {
      player?.pause()
      isPlaying = false
      player = nil
    }

  func setContentOf(urlStr: String) {
    guard let songURL = URL(string: urlStr) else {
        print("Invalid URL")
        return
    }
    player = try? AVAudioPlayer(contentsOf: songURL)
  }
  
  func getTotalTime() -> TimeInterval {
    player?.duration ?? 0.0
  }

  func getCurrentTime() -> TimeInterval {
    guard let player else { return TimeInterval(integerLiteral: 50)}
    return player.currentTime
  }

  func setCurrentTime(time: TimeInterval) {
    player?.currentTime = time
  }
}
