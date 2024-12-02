//
//  SearchListViews.swift
//  Psotify
//
//  Created by Turan, Kaan on 2.12.2024.
//

import SwiftUI

struct SearchListSectionView<Content: View>: View {
  let title: String
  let items: [Content]

  var body: some View {
    Section(
      header: Text(title)
        .font(.title2)
        .foregroundColor(.spotifyGreen)
        .padding(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
    ) {
      ForEach(Array(items.enumerated()), id: \.offset) { _, item in
        item
      }
    }
  }
}

struct SearchListCellView: View {
  let imageURL: URL?
  let title: String
  let subtitle: String

  var body: some View {
    HStack {
      AsyncImage(url: imageURL) { phase in
        if let image = phase.image {
          image
            .resizable()
            .scaledToFill()
            .frame(width: 50, height: 50)
            .cornerRadius(8)
        } else if phase.error != nil {
          Image(.placeHolder)
            .resizable()
            .scaledToFit()
            .frame(width: 50, height: 50)
            .cornerRadius(8)
        } else {
          ProgressView()
            .frame(width: 50, height: 50)
        }
      }
      .background(Color.gray.opacity(0.2))
      .cornerRadius(8)

      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.headline)
          .foregroundColor(.white)

        Text(subtitle)
          .font(.subheadline)
          .foregroundColor(.gray)
      }
      .padding(.leading, 8)

      Spacer()
    }
    .padding(.vertical, 5)
    .background(Color.black)
    .cornerRadius(10)
  }
}
