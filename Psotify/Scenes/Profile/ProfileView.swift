//
//  ProfileView.swift
//  Psotify
//
//  Created by Turan, Kaan on 25.11.2024.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.spotifyLightGray
                .ignoresSafeArea()

            VStack {
                switch viewModel.screenState {
                case .loaded:
                    loadedView
                case .error(let message):
                    ErrorView(message: message)
                default:
                    ErrorView(message: "Kullanıcı bilgileri alınamadı")
                }
            }
            .padding()
            .cornerRadius(16)
            .shadow(radius: 5)
        }
    }

    private var loadedView: some View {
        VStack(alignment: .leading, spacing: 20) {
            ProfileHeader(userModel: viewModel.userModel)
            Divider().background(Color.white.opacity(0.5))
            ProfileDetails(userModel: viewModel.userModel)
            Spacer()
        }
    }
}

struct ProfileHeader: View {
    var userModel: SpotifyUserProfile?

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            ProfileImage(urlString: userModel?.images.first?.url)
            VStack(alignment: .leading, spacing: 8) {
                Text(userModel?.displayName ?? "")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(userModel?.email ?? "")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                if let followers = userModel?.followers {
                    Text("Followers: \(followers.total)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                if let country = userModel?.country {
                    Text("Country: \(country)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

// MARK: - Profile Image View
struct ProfileImage: View {
    var urlString: String?

    var body: some View {
        AsyncImage(url: URL(string: urlString ?? "")) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .overlay(
                    Text("No Image")
                        .foregroundColor(.white)
                        .font(.caption)
                )
        }
        .frame(width: 100, height: 100)
        .clipShape(.circle)
        .shadow(radius: 5)
    }
}

struct ProfileDetails: View {
    var userModel: SpotifyUserProfile?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let product = userModel?.product.capitalized(with: .current) {
                Text("Product: \(product)")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }

            if let uri = userModel?.uri {
                Text("URI: \(uri)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        }
    }
}
