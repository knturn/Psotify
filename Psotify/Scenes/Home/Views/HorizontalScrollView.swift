//
//  HorizontalScrollView.swift
//  Psotify
//
//  Created by Turan, Kaan on 25.11.2024.
//

import SwiftUI

struct HorizontalScrollableView: View {
  @EnvironmentObject var nav: Navigation
  let title: String
  let albums: [Album]

  var body: some View {
    VStack(alignment: .leading) {
      Text(title)
        .font(.headline)
        .foregroundStyle(.spotifyGreen)
        .padding(.bottom, 8)

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 16) {
          ForEach(albums, id: \.id) { album in
            VStack {
              Image(album.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .cornerRadius(8)

              Text(album.title)
                .font(.caption)
                .lineLimit(1)
                .foregroundColor(.white)
            }
            .onTapGesture {
              nav.navigate(to: .albumDetail(id: album.albumID))
            }
          }
        }
      }
    }
  }
}

struct Album: Identifiable {
  let id = UUID()
  let albumID: String
  let title: String
  let imageName: String
}
