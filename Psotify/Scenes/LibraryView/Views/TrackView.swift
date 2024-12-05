//
//  TrackView.swift
//  Psotify
//
//  Created by Turan, Kaan on 4.12.2024.
//

import SwiftUI

struct TrackUIModel: Identifiable {
    let id: String
    let name: String
    let singer: String
    let imageURL: URL?


  init(id: String, name: String, imageURL: URL?, singer: String) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.singer = singer
    }
}

struct TrackView: View {
    @EnvironmentObject var nav: Navigation
    let track: TrackUIModel

    var body: some View {
        HStack {
            if let imageURL = track.imageURL {
                AsyncImage(url: imageURL) { image in
                    image.resizable()
                         .scaledToFit()
                         .frame(width: 50, height: 50)
                         .clipShape(RoundedRectangle(cornerRadius: 8))
                } placeholder: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(width: 50, height: 50)
                }
            } else {
                Image(systemName: "music.note")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading) {
                Text(track.name)
                    .font(.headline)
                    .lineLimit(1)
                    .padding(.bottom, 2)
              HStack {
                Text(track.singer )
                  .font(.subheadline)
                  .foregroundColor(.gray)
                  .lineLimit(1)
                Spacer()
                Button {
                  nav.navigate(to: .albumDetail(with: .init(id: track.id)))
                } label: {
                  Image(systemName: "arrow.forward.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)

                }

              }
            }
            .padding(.leading, 8)
        }
    }
}
