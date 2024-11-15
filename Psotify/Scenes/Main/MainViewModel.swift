//
//  MainViewModel.swift
//  Psotify
//
//  Created by Turan, Kaan on 15.11.2024.
//

import Foundation
final class MainViewModel: ObservableObject {
    var loginState: UserState = .login
}


enum UserState {
    case login
    case logout
    case inProgress
}
