//
//  ProfileViewModel.swift
//  Psotify
//
//  Created by Turan, Kaan on 27.11.2024.
//

import Combine

class ProfileViewModel: ObservableObject {
    @Published var userModel: SpotifyUserProfile?
    @Published var screenState: ScreenState = .error("Profil bilgisi bulunamadı.")

    init(userModel: SpotifyUserProfile?) {
        self.userModel = userModel

        if let _ = userModel {
            screenState = .loaded
        } else {
            screenState = .error("Profil bilgisi bulunamadı.")
        }
    }
}
