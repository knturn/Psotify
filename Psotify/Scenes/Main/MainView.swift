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
        TabBarView()
            .environmentObject(nav)
    }
}
