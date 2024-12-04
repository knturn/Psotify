//
//  TabbarView.swift
//  Psotify
//
//  Created by Turan, Kaan on 15.11.2024.
//

import SwiftUI

struct TabBarView: View {
  @EnvironmentObject var nav: Navigation

  init() {
    UITabBar.appearance().backgroundColor = .spotifyLightGray
    UITabBar.appearance().barTintColor = .spotifyLightGray
  }


  var body: some View {
    TabView(selection: $nav.selectedTab) {
      HomeView()
        .setNavPath($nav.homePath)
        .tabItem {
          Label("Home", systemImage: "house.fill")
        }
        .tag(Navigation.TabItem.home)

      SearchView()
        .setNavPath($nav.searchPath)
        .tabItem {
          Label("Search", systemImage: "magnifyingglass")
        }
        .tag(Navigation.TabItem.search)

      LibraryView()
        .setNavPath($nav.libraryPath)
        .tabItem {
          Label("Your Library", systemImage: "books.vertical.fill")
        }
        .tag(Navigation.TabItem.library)
    }
    .accentColor(.spotifyGreen)
  }
}
