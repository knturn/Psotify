//
//  View+Extensions.swift
//  Psotify
//
//  Created by Turan, Kaan on 15.11.2024.
//

import SwiftUI

extension View {
    func setNavPath(_ path: Binding<NavigationPath>) -> some View {
        modifier(NavigationModifier(path: path))
    }
}
