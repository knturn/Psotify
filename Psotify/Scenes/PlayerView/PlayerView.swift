//
//  PlayerView.swift
//  Psotify
//
//  Created by Turan, Kaan on 1.12.2024.
//

import SwiftUI

struct PlayerView: View {
    @StateObject private var playerManager: PlayerManager
    @StateObject private var viewModel: PlayerViewModel

  init(viewModel: PlayerViewModel, playerManager: PlayerManager = .shared) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _playerManager = StateObject(wrappedValue: playerManager)
    }

    var body: some View {
        VStack {
            headerView
            albumArtView
            songDetailsView
            progressView
            controlButtons
          
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .leastNormalMagnitude)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .task {
          viewModel.fetchSong()
        }
        .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { [weak viewModel] _ in
          viewModel?.updateCurrentTime()
        }
        .onDisappear { [weak playerManager] in
          playerManager?.close()
        }
    }
}

private extension PlayerView {
    var headerView: some View {
        ZStack {
            HStack {
                ModifiedButtonView(image: "arrow.left")
                Spacer()
                ModifiedButtonView(image: "line.horizontal.3.decrease")
            }

            Text("Now Playing")
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding()
    }

    var albumArtView: some View {
      AsyncImage(url: viewModel.song?.album?.images?.first?.imageURL) { phase in
        if let image = phase.image {
          image
            .resizable()
            .scaledToFit()
            .cornerRadius(8)
        } else if phase.error != nil {
          Image(.placeHolder)
            .resizable()
            .scaledToFit()
            .cornerRadius(8)
        } else {
          ProgressView()
        }
      }
        .frame(width: 300, height: 300)
        .clipShape(.circle)
        .shadow(color: Color.green.opacity(0.3), radius: 10, x: 5, y: 5)
        .padding(.top, 35)
        .background(Color.black.ignoresSafeArea())
        .clipShape(.circle)
    }

    var songDetailsView: some View {
        VStack(spacing: 5) {
            Text(viewModel.song?.name ?? "Şarkı Adı")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(viewModel.song?.artists?.first?.name ?? "Sanatçı")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.top, 25)
    }

    var progressView: some View {
        VStack {
            HStack {
                Text(viewModel.timeString(for: viewModel.currentTime))
                Spacer()
                Text(viewModel.timeString(for: viewModel.totalTime))
            }
            .font(.caption)
            .foregroundColor(.white)
            .padding([.top, .horizontal], 20)

            Slider(value: Binding(get: {
                viewModel.currentTime
            }, set: { [weak playerManager] newValue in
                playerManager?.setCurrentTime(time: newValue)
            }), in: 0...viewModel.totalTime)
            .accentColor(.spotifyGreen)
            .padding([.top, .horizontal], 20)
        }
    }

    // MARK: - Control Buttons
    var controlButtons: some View {
        HStack(spacing: 20) {
            ModifiedButtonView(image: "backward.fill")

            playPauseButtonContent
                .onTapGesture {
                    togglePlayPause()
                }

            ModifiedButtonView(image: "forward.fill")
        }
        .padding(.top, 25)
    }

    var playPauseButtonContent: some View {
        Image(systemName: playerManager.isPlaying ? "pause.fill" : "play.fill")
            .font(.system(size: 14, weight: .bold))
            .padding(25)
            .foregroundColor(.black)
            .background(
                Circle()
                    .fill(.spotifyGreen)
            )
    }

    // MARK: - Helper Functions
    func togglePlayPause() {
        if playerManager.isPlaying {
            playerManager.pause()
        } else {
            playerManager.playSong()
        }
    }
}
