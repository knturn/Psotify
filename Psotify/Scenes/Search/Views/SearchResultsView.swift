//
//  SearchResultsView.swift
//  Psotify
//
//  Created by Turan, Kaan on 2.12.2024.
//

import SwiftUI

struct ResultsView: View {
  @EnvironmentObject var nav: Navigation
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
              items: searchedSongs.map { song in
                SearchListCellView(
                  imageURL: song.album?.images.first?.imageURL,
                  title: song.name ?? "Unknown Song",
                  subtitle: song.artists?.first?.name ?? "Unknown Artist",
                  onTap: { [weak nav] in
                    guard let nav = nav else { return }
                    nav.navigate(to: .playerView(with: .init(id: song.id)))
                  }
                )
              }
            )
          }

          if !searchedAlbums.isEmpty {
            SearchListSectionView(
              title: "Albums",
              items: searchedAlbums.map { album in
                SearchListCellView(
                  imageURL: album.images.first?.imageURL,
                  title: album.name,
                  subtitle: album.artists.first?.name ?? "Unknown Artist",
                  onTap: { [weak nav] in
                    guard let nav = nav else { return }
                    nav.navigate(to: .albumDetail(with: .init(id: album.id)))
                  }

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


