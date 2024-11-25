//
//  SectionGridView.swift
//  Psotify
//
//  Created by Turan, Kaan on 25.11.2024.
//

import SwiftUI

struct SectionView: View {
  @EnvironmentObject var nav: Navigation
  let title: String
  let gridItems: [Album]

  private let gridLayout = [
    GridItem(.flexible()),
    GridItem(.flexible())
  ]

  var body: some View {
    VStack(alignment: .leading) {
      Text(title)
        .font(.headline)
        .foregroundStyle(.spotifyGreen)
        .padding(.bottom, 8)

      LazyVGrid(columns: gridLayout, spacing: 16) {
        ForEach(gridItems, id: \.id) { song in
          HStack {
            Image(song.imageName)
              .resizable()
              .scaledToFit()
              .frame(height: 80)
              .cornerRadius(8)

            Text(song.title)
              .font(.caption)
              .lineLimit(1)
              .foregroundColor(.white)
              .padding(.leading, 20)
          }
          .onTapGesture {
            nav.navigate(to: .albumDetail(id: song.albumID))
          }
        }
      }
    }
  }
}
