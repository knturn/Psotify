//
//  Launch.swift
//  Psotify
//
//  Created by Turan, Kaan on 15.11.2024.
//

import SwiftUI

struct LaunchView: View {
    var body: some View {
        Images.launchScreen.image
            .renderingMode(.original)
            .scaledToFit()
    }
}


#Preview {
    LaunchView()
}
