//
//  SectionGridView.swift
//  Psotify
//
//  Created by Turan, Kaan on 25.11.2024.
//

import SwiftUI

struct SectionView: View {
  @EnvironmentObject var nav: Navigation
  private var sectionGridViewUIModel: SectionGridViewUIModel

  init(sectionGridViewUIModel: SectionGridViewUIModel) {
    self.sectionGridViewUIModel = sectionGridViewUIModel
  }


  private let gridLayout = [
    GridItem(.flexible()),
    GridItem(.flexible())
  ]

  var body: some View {
    VStack(alignment: .leading) {
      Text(sectionGridViewUIModel.title)
        .font(.headline)
        .foregroundStyle(.spotifyGreen)
        .padding(.bottom, 8)

      LazyVGrid(columns: gridLayout, spacing: 10) {
        if let items = sectionGridViewUIModel.gridItems {
          ForEach(items, id: \.id) { albumItem in
            HStack(spacing: 10) {
              AsyncImage(url: URL(string: albumItem.images.first?.url ?? ""),
                         content: { image in
                image
                  .resizable()
                  .scaledToFit()
              }, placeholder: {
                Image(.placeHolder)
                  .resizable()
              })
              .scaledToFit()
              .frame(width: 80, height: 80)
              .cornerRadius(8)

              Text(albumItem.name)
                .lineLimit(2)
                .padding(.leading, 5)
                .font(.caption)
                .foregroundColor(.white)

              Spacer()
            }
            .onTapGesture {
              nav.navigate(to: .albumDetail(with: .init(id: albumItem.id)))
            }
          }
        }
      }
    }
  }
}
