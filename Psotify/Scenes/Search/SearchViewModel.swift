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

    var showCouldntFileLabel: Bool {
        guard query.count >= 3 else { return false }
        return !thereAnyResult
    }

    private let getSearchResultUseCase: GetSearchResultProtocol
    private var result: SearchResponse?
    private var cancellables = Set<AnyCancellable>()

    init(getSearchResultUseCase: GetSearchResultProtocol = AppDIContainer.shared.resolve(GetSearchResultProtocol.self)) {
        self.getSearchResultUseCase = getSearchResultUseCase
        observeQueryChanges()
    }

    func performSearch() async {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedQuery.count < 3 {
            filterResults(for: trimmedQuery)
            return
        }

        await fetchSearchResults(for: trimmedQuery)
    }
}

//MARK: Private Funcs
extension SearchViewModel {
  @MainActor
      private func fetchSearchResults(for query: String) async {
          updateScreenState(to: .isLoading)

          do {
              let results = try await getSearchResultUseCase.fetchResult(with: query, for: ["album", "track"])
              self.result = results

              guard let result else {
                updateScreenState(to: .error("Sonuç bulunamadı"))
                return
              }
              self.searchedAlbums = result.albums?.items ?? []
              self.searchedSongs = result.tracks?.items ?? []
              self.updateScreenState(to: .loaded)
          } catch {
              updateScreenState(to: .error(error.localizedDescription))
          }
      }

      private func filterResults(for query: String) {
          DispatchQueue.main.async { [weak self] in
              guard let self = self else { return }
              self.updateScreenState(to: .isLoading)

              self.searchedAlbums = self.searchedAlbums.filter { $0.name.localizedCaseInsensitiveContains(query) }
              self.searchedSongs = self.searchedSongs.filter { $0.name?.localizedCaseInsensitiveContains(query) == true }

              self.updateScreenState(to: .loaded)
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
                  Task {
                      await self.performSearch()
                  }
              }
              .store(in: &cancellables)
      }

      private var thereAnyResult: Bool {
          !searchedSongs.isEmpty || !searchedAlbums.isEmpty
      }
}

