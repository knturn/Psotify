//
//  AlbumDetailView.swift
//  Psotify
//
//  Created by Turan, Kaan on 28.11.2024.
//

import SwiftUI

struct AlbumDetailView: View {
  @StateObject var viewModel: AlbumDetailViewModel

  init(viewModel: AlbumDetailViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }

  var body: some View {
    Group {
      switch viewModel.screenState {
      case .isLoading:
        loadingView
      case .loaded:
        loadedView
      case .error(let message):
        errorView(message: message)
      }
    }
    .background(Color.spotifyMediumGray)
    .onAppear {
      Task {
        await viewModel.fetchSongList()
      }
    }
  }

  private var loadingView: some View {
    SkeletonPlaceHolderView(columns: 1, itemHeight: 70, spacing: 16) {
      HStack(spacing: 16) {
        RoundedRectangle(cornerRadius: 8)
          .fill(Color.gray.opacity(0.3))
          .frame(width: 50, height: 50)

        VStack(alignment: .leading, spacing: 8) {
          RoundedRectangle(cornerRadius: 4)
            .fill(Color.gray.opacity(0.3))
            .frame(height: 16)

          RoundedRectangle(cornerRadius: 4)
            .fill(Color.gray.opacity(0.3))
            .frame(width: 80, height: 16)
        }
      }
    }
  }

  private var loadedView: some View {
    VStack {
      listHeader()
        .padding()
      List(viewModel.songList?.tracks?.items ?? [], id: \.id) { track in
        trackRow(for: track)
      }
      .listStyle(.plain)
      .background(.clear)
    }
  }

  private func trackRow(for track: TrackItem) -> some View {
    HStack {
      albumPoster()
        .scaledToFit()
        .frame(width: 50, height: 50)
        .cornerRadius(8)
      VStack(alignment: .leading, spacing: 4) {
        Text(track.name ?? "No name")
          .font(.headline)
          .foregroundColor(.white)

        Text(track.artists?.first?.name ?? "Sanatçı")
          .font(.subheadline)
          .foregroundColor(.gray)
      }
    }
    .listRowBackground(Color.spotifyLightGray)
  }

  private func listHeader() -> some View {
    ZStack(alignment: .bottomLeading) {
      albumPoster()
        .frame(height: 200)
        .clipped()
        .cornerRadius(8)
      VStack(alignment: .leading) {
        Text(viewModel.songList?.name ?? "Album")
          .font(.title)
          .fontWeight(.bold)
          .foregroundColor(.white)
          .shadow(radius: 5)
      }
    }
  }

  private func errorView(message: String) -> some View {
    ErrorView(message: message)
      .padding()
  }

  private func albumPoster() -> some View {
    AsyncImage(url: viewModel.songList?.images.randomElement()?.imageURL) { image in
      image
        .resizable()
    } placeholder: {
      Image(.placeHolder)
        .resizable()
    }
  }
}
