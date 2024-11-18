//
//  MainView.swift
//  Psotify
//
//  Created by Turan, Kaan on 15.11.2024.
//

import SwiftUI

struct MainView: View {
    @StateObject var nav = Navigation()
    @StateObject var viewModel = MainViewModel()

    
    var body: some View {
        Group {
            switch viewModel.loginState {
            case .login:
                TabBarView()
            case .logout:
                LoginView(viewModel: LoginViewModel())
            case .inProgress:
                LaunchView()
                    .onAppear {
                        Task {
                         try await viewModel.authUseCase.checkLoginState()
                        }
                    }
            }
        }
        .environmentObject(nav)
    }
}
