//
//  ErrorView.swift
//  Psotify
//
//  Created by Turan, Kaan on 28.11.2024.
//

import SwiftUI

struct ErrorView: View {
    let title: String
    let message: String

  init(title: String = "Hata", message: String) {
    self.title = title
    self.message = message
  }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 16) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.red)
                Text(message)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.spotifyXLightGray)
            .frame(width: geometry.size.width, height: geometry.size.height)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}


#Preview {
  ErrorView(title: "Hata", message: "Yeniden deneyin")
}
