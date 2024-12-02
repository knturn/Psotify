//
//  SearchViewModel.swift
//  Psotify
//
//  Created by Turan, Kaan on 2.12.2024.
//

import SwiftUI
import Combine

final class SearchViewModel: ObservableObject {
    @Published var searchedSongs: [TrackItem] = []
    @Published var searchedAlbums: [AlbumItem] = []
    @Published var screenState: ScreenState = .loaded
    @Published var query: String = ""
    private var result: SearchResponse?
    private let getSearchResultUseCase: GetSearchResultProtocol

    private var cancellables = Set<AnyCancellable>()

  init(getSearchResultUseCase: GetSearchResultProtocol = AppDIContainer.shared.resolve(GetSearchResultProtocol.self)) {
        self.getSearchResultUseCase = getSearchResultUseCase
        observeQueryChanges()
    }

    func performSearch() async {
      self.updateScreenState(to: .isLoading)
        do {
          let results: SearchResponse = try await getSearchResultUseCase.fetchResult(with: query, for: ["album", "track"])
          self.result = results
          guard let result else { 
            self.updateScreenState(to: .error("No results found."))
            return
          }
          DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.searchedAlbums = result.albums?.items ?? []
            self.searchedSongs = result.tracks?.items ?? []
            self.updateScreenState(to: .loaded)
          }
        } catch {
            self.updateScreenState(to: .error(error.localizedDescription))
        }
    }

    private func updateScreenState(to state: ScreenState) {
        DispatchQueue.main.async { [weak self] in
            self?.screenState = state
        }
    }

  private func observeQueryChanges() {
      $query
          .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
          .removeDuplicates()
          .sink { [weak self] newQuery in
              guard let self = self else { return }
            if query.count >= 3 {
              Task {
                  await self.performSearch()
              }
            } 
            guard query.isEmpty else { return }
            
            DispatchQueue.main.async {
              self.searchedSongs = []
              self.searchedAlbums = []
            }
          }
          .store(in: &cancellables)
  }
}
