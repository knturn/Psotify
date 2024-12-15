//
//  SearchErrorView.swift
//  Psotify
//
//  Created by Turan, Kaan on 2.12.2024.
//

import SwiftUI

struct SearchErrorView: View {
  let errorMessage: String
  let retryAction: () -> Void

  var body: some View {
    VStack {
      Text(errorMessage)
        .foregroundColor(.spotifyGreen)
        .multilineTextAlignment(.center)

      Button("Tekrar dene", action: retryAction)
        .foregroundColor(.white)
        .padding()
        .background(Color.spotifyGreen)
        .cornerRadius(8)
    }
  }
}
