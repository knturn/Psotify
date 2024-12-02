//
//  ModifiedButtonView.swift
//  Psotify
//
//  Created by Turan, Kaan on 1.12.2024.
//

import SwiftUI

struct ModifiedButtonView: View {
    var image: String

    var body: some View {
        Button(action: {}, label: {
            Image(systemName: image)
                .font(.system(size: 14, weight: .bold))
                .padding(.all, 25)
                .foregroundColor(.white)
                .background(
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                              gradient: Gradient(colors: [.black, .spotifyGreen]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))

                        Circle()
                            .foregroundColor(.black)
                            .blur(radius: 8)
                            .offset(x: -6, y: -6)

                        Circle()
                            .fill(LinearGradient(
                              gradient: Gradient(colors: [Color.green.opacity(0.7), .clear]),
                                startPoint: .topTrailing,
                                endPoint: .bottomLeading
                            ))
                            .padding(4)
                            .blur(radius: 4)
                    }
                      .clipShape(.circle)
                    .shadow(color: Color.green.opacity(0.3), radius: 12, x: 8, y: 8)
                    .shadow(color: Color.black.opacity(0.5), radius: 12, x: -8, y: -8)
                )
        })
    }
}

