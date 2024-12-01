//
//  HomeView.swift
//  Psotify
//
//  Created by Turan, Kaan on 21.11.2024.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var nav: Navigation
    @StateObject private var viewModel: HomeViewModel

  init(viewModel: HomeViewModel = .init()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView
                .padding(.horizontal)
                .padding(.top, 16)

            ScrollView {
                switch viewModel.screenState {
                case .isLoading:
                    placeholder
                case .loaded:
                    contentView
                        .padding(.horizontal)
                case .error(let message):
                   ErrorView(message: message)
                }
            }
        }
        .task {
            await viewModel.fetchNewReleases()
            await viewModel.fetchUserPlaylists()
            await viewModel.fetchUserProfile()
        }
        .background(.spotifyMediumGray)
    }

    private var headerView: some View {
        HStack {
            Text("Merhaba " + (viewModel.userModel?.displayName ?? ""))
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Spacer()

            Button(action: {
                nav.navigate(to: .userDetail(with: viewModel.userModel))
            }) {
                Image(systemName: "person.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
        }
    }

  private var placeholder: some View {
    SkeletonPlaceHolderView() {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 120)

            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 16)

            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 80, height: 16)
        }
    }
  }

    private var contentView: some View {
        LazyVStack(spacing: 32) {
            SectionView(
              sectionGridViewUIModel: .init(title: "HOT Albums", gridItems: viewModel.newReleases)
            )
            ForEach(viewModel.featuredPlayList ?? [], id: \.id) { item in
              HorizontalScrollableView(model: viewModel.createHorizontalScrollUIModel(item.id))
                    .onAppear {
                        Task {
                            await viewModel.fetchPlaylist(for: item.id)
                        }
                    }
            }
        }
    }
}
