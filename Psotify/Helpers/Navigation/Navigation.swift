//
//  Navigation.swift
//  Psotify
//
//  Created by Turan, Kaan on 15.11.2024.
//

import SwiftUI

class Navigation: ObservableObject {
  @Published var selectedTab: TabItem = .home
  @Published var homePath: NavigationPath = NavigationPath()
  @Published var searchPath: NavigationPath = NavigationPath()
  @Published var libraryPath: NavigationPath = NavigationPath()

  func selectTab(_ tabItem: TabItem) {
    selectedTab = tabItem
  }

  func navigate(to viewType: ViewType) {
    switch selectedTab {
    case .home:
      homePath.append(viewType)
    case .search:
      searchPath.append(viewType)
    case .library:
      libraryPath.append(viewType)
    }
  }

  func popToRoot() {
    switch selectedTab {
    case .home:
      homePath.removeLast(homePath.count)
    case .search:
      searchPath.removeLast(searchPath.count)
    case .library:
      libraryPath.removeLast(libraryPath.count)
    }
  }

  enum TabItem {
    case home, search, library
  }

  enum ViewType: Hashable {
    case albumDetail(id: String)
    case userDetail(with: SpotifyUserProfile?)
    case searchDetail(id: String)
    case libraryDetail(id: String)
  }
}

extension Navigation.ViewType {
  @ViewBuilder var view: some View {
    switch self {
    case .userDetail(with: let model):
      ProfileView(viewModel: .init(userModel: model))
    case .albumDetail(id: let id):
      Text("Albüm List \(id)")
    case .searchDetail(_):
      Text("Search Detail")
    case .libraryDetail(_):
      Text("Library Detail")
    }
  }
}
