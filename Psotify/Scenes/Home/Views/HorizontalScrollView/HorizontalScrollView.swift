//
//  HorizontalScrollView.swift
//  Psotify
//
//  Created by Turan, Kaan on 25.11.2024.
//
//
import SwiftUI

struct HorizontalScrollableView: View {
  @EnvironmentObject var nav: Navigation
  private let model: HorizontalScrollViewUIModel?

  init(model: HorizontalScrollViewUIModel?) {
    self.model = model
  }

  var body: some View {
    VStack(alignment: .leading) {
      Text(model?.title ?? "Playlist")
        .font(.headline)
        .foregroundStyle(.spotifyGreen)

      Text(model?.description ?? "Based on your mood")
        .font(.subheadline)
        .foregroundStyle(.blue)
        .padding(.vertical, 5)

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 16) {
          if let tracks = model?.tracks {
            ForEach(tracks) { track in
              VStack {
                AsyncImage(url: model?.imageURL) { image in
                  image
                    .resizable()
                } placeholder: {
                  Image(.placeHolder)
                    .resizable()
                }
                .scaledToFit()
                .frame(width: 100, height: 100)
                .cornerRadius(8)

                Text(track.track?.name ?? "Unknown Track")
                  .font(.caption)
                  .lineLimit(1)
                  .foregroundColor(.white)
              }
              .onTapGesture {
                if let trackId = track.track?.id {
                  let viewModel = PlayerViewModel(id: trackId)
                  nav.navigate(to: .playerView(with: viewModel))
                }
              }
            }
          } 
        }
      }
    }
  }
}

