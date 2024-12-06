//
//  SearchView.swift
//  Psotify
//
//  Created by Turan, Kaan on 2.12.2024.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel

    init(viewModel: SearchViewModel = .init()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            searchBar

            Spacer()

            switch viewModel.screenState {
            case .isLoading:
              ProgressView("Loading...")
                  .progressViewStyle(CircularProgressViewStyle())
                  .foregroundColor(.spotifyGreen)
                  .padding()

            case .loaded:
                ResultsView(
                    searchedSongs: viewModel.searchedSongs,
                    searchedAlbums: viewModel.searchedAlbums,
                    showLabel: viewModel.showCouldntFileLabel
                )

            case .error(let errorMessage):
              SearchErrorView(errorMessage: errorMessage) {
                    Task {
                        await viewModel.performSearch()
                    }
                }
            }

            Spacer()
        }
        .background(Color.black.ignoresSafeArea())
    }

  private var searchBar: some View {
      HStack {
          TextField("Search for songs or albums", text: $viewModel.query)
              .textFieldStyle(.plain)
              .padding()
              .background(.spotifyXLightGray)
              .cornerRadius(10)
              .foregroundColor(.white)
              .accentColor(.spotifyGreen)

          if !viewModel.query.isEmpty {
            clearButton
          }
      }
      .padding(.horizontal)
  }

  private var clearButton: some View {
    Button(action: {
        viewModel.query = ""
    }) {
        Image(systemName: "xmark.circle.fill")
            .foregroundColor(.gray)
            .padding(8)
    }
  }
}