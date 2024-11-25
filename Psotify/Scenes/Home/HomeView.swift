//
//  HomeView.swift
//  Psotify
//
//  Created by Turan, Kaan on 21.11.2024.
//

import SwiftUI

struct HomeView: View {
  @EnvironmentObject var nav: Navigation

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack {
        Text("Merhaba, Kaan")
          .font(.title)
          .fontWeight(.bold)
          .foregroundStyle(.white)

        Spacer()

        Button(action: {
          nav.navigate(to: .userDetail)
        }) {
          Image(systemName: "person.fill")
            .font(.title2)
            .foregroundColor(.white)
        }
      }
      .padding(.horizontal)
      .padding(.top, 16)

      ScrollView {
        VStack(spacing: 32) {
          SectionView(
            title: "Tavsiye Şarkılar",
            gridItems: recommendedSongs
          )

          ForEach(recommendedSongs, id: \.title) { section in
            HorizontalScrollableView(
              title: section.title, albums: recommendedSongs
            )
          }
        }

        .padding(.horizontal)
      }
    }
    .background(Color.spotifyMediumGray)
  }
}

// Example
let recommendedSongs = [
  Album(albumID: "2342", title: "Song A", imageName: "placeHolder"),
  Album(albumID: "2342", title: "Song B", imageName: "placeHolder"),
  Album(albumID: "2342", title: "Song C", imageName: "placeHolder"),
  Album(albumID: "2342", title: "Song D", imageName: "placeHolder"),
  Album(albumID: "2342", title: "Song E", imageName: "placeHolder"),
  Album(albumID: "2342", title: "Song F", imageName: "placeHolder")
]


#Preview {
  HomeView()
}
