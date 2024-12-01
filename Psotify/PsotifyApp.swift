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
    setupDIContainer(with: diContainer)
  }
  var body: some Scene {
    WindowGroup {
      MainView()
        .preferredColorScheme(.dark)
        .environmentObject(diContainer.makeNavigation())
    }
  }
}
