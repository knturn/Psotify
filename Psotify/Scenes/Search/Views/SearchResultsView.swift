//
//  SearchResultsView.swift
//  Psotify
//
//  Created by Turan, Kaan on 2.12.2024.
//

import SwiftUI

struct ResultsView: View {
  let searchedSongs: [TrackItem]
  let searchedAlbums: [AlbumItem]
  let showLabel: Bool

  var body: some View {
    if searchedSongs.isEmpty && searchedAlbums.isEmpty {
      VStack(spacing: 20) {
        Image(systemName: "magnifyingglass")
          .resizable()
          .scaledToFit()
          .frame(width: 100, height: 100)
          .foregroundColor(.gray)
        if showLabel {
          Text("Couldn't find any results")
            .font(.title3)
            .foregroundColor(.gray)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.black.ignoresSafeArea())
    } else {
      ScrollView {
        LazyVStack(spacing: 10) {
          if !searchedSongs.isEmpty {
            SearchListSectionView(
              title: "Songs",
              items: searchedSongs.map {
                SearchListCellView(
                  imageURL: $0.album?.images.first?.imageURL,
                  title: $0.name ?? "Unknown Song",
                  subtitle: $0.artists?.first?.name ?? "Unknown Artist",
                  detailViewType: .playerView(with: .init(id: $0.id))
                )
              }
            )
          }

          if !searchedAlbums.isEmpty {
            SearchListSectionView(
              title: "Albums",
              items: searchedAlbums.map {
                SearchListCellView(
                  imageURL: $0.images.first?.imageURL,
                  title: $0.name,
                  subtitle: $0.artists.first?.name ?? "Unknown Artist",
                  detailViewType: .albumDetail(with: .init(id: $0.id))
                )
              }
            )
          }
        }
        .padding(.horizontal)
      }
      .background(Color.black.ignoresSafeArea())
    }
  }
}


