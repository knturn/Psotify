//
//  PsotifyApp.swift
//  Psotify
//
//  Created by Turan, Kaan on 15.11.2024.
//

import SwiftUI

@main
struct PsotifyApp: App {
    let nav = Navigation()
    
    var body: some Scene {
        WindowGroup {
            MainView()
            .environmentObject(nav)
            .task {
              do {
                  try Configuration.validate()
              } catch {
                  fatalError("Configuration Error: \(error)")
              }
            }
        }
    }
}
