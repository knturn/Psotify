//
//  Navigation+Modifier.swift
//  Psotify
//
//  Created by Turan, Kaan on 15.11.2024.
//

import SwiftUI

struct NavigationModifier: ViewModifier {
    let path: Binding<NavigationPath>
    func body(content: Content) -> some View {
        NavigationStack(path: path) {
            content.navigationDestination(for: Navigation.ViewType.self) { viewType in
                viewType.view
            }
        }
        .toolbarRole(.navigationStack)
    }
}
