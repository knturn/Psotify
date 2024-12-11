//
//  MainView.swift
//  Psotify
//
//  Created by Turan, Kaan on 15.11.2024.
//

import SwiftUI

struct MainView: View {
  @EnvironmentObject var nav: Navigation
  @StateObject var viewModel: MainViewModel

  init(viewModel: MainViewModel = .init()) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }

  var body: some View {
    Group {
      switch viewModel.loginState {
      case .login:
        TabBarView()
      case .logout:
        LoginView()
      case .inProgress:
        LaunchView()
          .task {
            viewModel.refreshLoginState()
          }
      }
    }
  }
}
