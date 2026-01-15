//
//  HomeViewModel.swift
//  RickyMortyApp
//
//  Created by Angelber Castro on 1/12/26.
//

import Factory
import Observation
import SwiftUI

@Observable
final class HomeViewModel {
    @ObservationIgnored var getCharactersUseCase: GetCharactersUseCase
    @ObservationIgnored private var searchDebounceTask: Task<Void, Never>?

    init() {
        self.getCharactersUseCase = GetCharactersUseCaseImpl()
    }

     init(useCase: GetCharactersUseCase) {
        self.getCharactersUseCase = useCase
    }
    
    var characters: [Character] = []
    var isLoading: Bool = false
    var error: Error?
    var currentPage: Int = 1
    var hasNextPage: Bool = false

    var searchText: String = "" {
        didSet {
            // validates if the value is different from oldValue
            guard searchText != oldValue else {
                return
            }
            searchDebounceTask?.cancel()
            
            // Compare the trimmed values ​​to see if the valid content actually changed.
            let trimmedText = searchText.trimmingCharacters(in: .whitespaces)
            let trimmedOldValue = oldValue.trimmingCharacters(in: .whitespaces)
            

            // Validation: If there is a space before and after the value, the search stops.
            guard trimmedText != trimmedOldValue else {
                return
            }

            guard !trimmedText.isEmpty else {
                // If the search field is cleared, clear the 404 error immediately and synchronously.
                if isNotFoundError {
                    self.error = nil
                }
                
                if !trimmedOldValue.isEmpty {
                    searchDebounceTask = Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(400))
                        if !Task.isCancelled {
                            await performSearch()
                        }
                    }
                }
                return
            }

            if isNotFoundError {
                self.error = nil
            }

            searchDebounceTask = Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(400))

                if !Task.isCancelled && !self.searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                    await performSearch()
                }
            }
        }
    }
    
    /// FILTER: Selected state to filter characters.
    var selectedStatus: CharacterStatus = .all {
        didSet {
            Task {
                await performSearch()
            }
        }
    }

    
    /// SEARCH AND FILTER: Runs the search by restarting to page 1 and clearing results.
    @MainActor
    func performSearch() async {
        currentPage = 1
        characters = []

        await loadCharacters()
    }

    /// SEARCH, FILTERING AND PAGINATION: Load characters according to current criteria.
    func loadCharacters() async {
        isLoading = true
        error = nil

        do {

            // trimmingCharacters It allows us to remove spaces from a character.
            let name = searchText.trimmingCharacters(in: .whitespaces).isEmpty ? nil : searchText
            
            // FILTER BY STATE:
            let status = selectedStatus.apiValue

            let response = try await getCharactersUseCase.invoke(
                page: currentPage,
                name: name,
                status: status
            )

            await MainActor.run {
                if self.currentPage == 1 {
                    // Page 1: Replace the entire list (new search/filter or initial load)
                    self.characters = response.results
                } else {
                    // Next pages: Add to end for infinite scroll
                    // append(contentsOf:) adds new characters without deleting previous ones
                    self.characters.append(contentsOf: response.results)
                }

                self.hasNextPage = response.info.next != nil

                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
        }
    }
    
    /// INFINITE SCROLL: Load the next character page
    func loadNextPage() async {
        guard hasNextPage, !isLoading else { return }
        currentPage += 1
        await loadCharacters()
    }
    
    /// INFINITE SCROLL: Determines whether more content should be loaded

    func shouldLoadMore(currentItem character: Character) -> Bool {
        guard let lastCharacter = characters.last else { return false }
        // Check if the character that appeared is the last one on the list
        return character.id == lastCharacter.id && hasNextPage && !isLoading
    }
    
    /// Retry loading characters after an error.
    func retry() async {
        currentPage = 1
        await loadCharacters()
    }

    var isNotFoundError: Bool {
        guard let error = error as? NetworkError else { return false }
        
        switch error {
        case .serverError(let code):
            return code == 404
        case .serverErrorWithMessage(let code, _, _):
            return code == 404
        default:
            return false
        }
    }
    
    /// Indicates whether the "not found" message should be displayed instead of the ErrorView
    var shouldShowNotFoundMessage: Bool {
        isNotFoundError && !searchText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// This prevents memory leaks and tasks from running after the ViewModel no longer exists.
    deinit {
        searchDebounceTask?.cancel()
    }
}

