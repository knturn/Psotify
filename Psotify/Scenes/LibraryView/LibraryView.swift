//
//  LibraryView.swift
//  Psotify
//
//  Created by Turan, Kaan on 3.12.2024.
//

import SwiftUI

struct LibraryView: View {
    @StateObject private var libraryViewModel: LibraryViewModel

    init(libraryViewModel: LibraryViewModel = .init()) {
        _libraryViewModel = StateObject(wrappedValue: libraryViewModel)
    }

    var body: some View {
        VStack {
            switch libraryViewModel.screenState {
            case .isLoading:
                loadingView
            case .loaded:
                loadedView
            case .error(let message):
                ErrorView(message: message)
            }
        }
        .task { libraryViewModel.fetch() }
        .navigationTitle("Top Tracks")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Loading View
    private var loadingView: some View {
        SkeletonPlaceHolderView(columns: 1, itemHeight: 90, spacing: 10) {
            HStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)

                VStack(alignment: .leading, spacing: 6) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 20)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 15)
                }
                .padding(.leading, 8)
            }
            .padding(.vertical, 8)
        }
        .padding()
    }

  // MARK: - Loaded View
  private var loadedView: some View {
      Group {
          if let tracks = libraryViewModel.getTrackItems() {
              List(tracks, id: \.track.uri) { item in
                TrackView(track: libraryViewModel.getTrackUIModel(item))
                  .padding(.vertical, 8)
              }
              .listStyle(.plain)
          } else {
              Text("No tracks available")
                  .font(.subheadline)
                  .foregroundColor(.gray)
                  .padding()
          }
      }
    }
  }
