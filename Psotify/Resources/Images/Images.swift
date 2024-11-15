//
//  Images.swift
//  Psotify
//
//  Created by Turan, Kaan on 15.11.2024.
//

import SwiftUI

enum Images: String, CaseIterable {
    case launchScreen
    case loginLogo
    var image: Image {
        Image(rawValue)
    }
}

extension Image {
    static let launchScreen = Images.launchScreen.image
    static let loginLogo = Images.loginLogo.image
}
