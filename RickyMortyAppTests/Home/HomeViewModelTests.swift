//
//  HomeViewModelTests.swift
//  RickyMortyAppTests
//
//  Created by Angelber Castro on 1/14/26.
//

import Testing
import Foundation
@testable import RickyMortyApp

extension Tag {
    @Tag static var viewModel: Self
    @Tag static var search: Self
    @Tag static var filter: Self
    @Tag static var stateTransition: Self
}

@Suite("HomeViewModel Tests", .tags(.viewModel))
struct HomeViewModelTests {
    var mockUseCase: MockGetCharactersUseCase!
    var viewModel: HomeViewModel!

    init() {
        setup()
    }

    mutating func setup() {
        mockUseCase = MockGetCharactersUseCase()
        viewModel = HomeViewModel(useCase: mockUseCase)
    }

    // MARK: - State Transition Tests

    @Test("State Transition: idle → loading → success", .tags(.stateTransition))
    func testStateTransitionIdleToLoadingToSuccess() async throws {
        // GIVEN: Initial ViewModel with no data and mock configured for success response
        let mockCharacters = [
            MockGetCharactersUseCase.createSimpleMockCharacter(id: 1, name: "Rick Sanchez", status: "Alive"),
            MockGetCharactersUseCase.createSimpleMockCharacter(id: 2, name: "Morty Smith", status: "Alive")
        ]
        mockUseCase.mockResponse = MockGetCharactersUseCase.createMockResponse(
            characters: mockCharacters,
            hasNextPage: false
        )

        await MainActor.run {
            #expect(viewModel.characters.isEmpty == true)
            #expect(viewModel.isLoading == false)
            #expect(viewModel.error == nil)
        }

        // WHEN: Character loading is executed
        await viewModel.loadCharacters()

        // THEN: The state should be success with characters loaded
        await MainActor.run {
            #expect(viewModel.isLoading == false)
            #expect(viewModel.error == nil)
            #expect(viewModel.characters.count == 2)
            #expect(viewModel.characters[0].name == "Rick Sanchez")
            #expect(viewModel.characters[0].status == "Alive")
            #expect(viewModel.characters[1].name == "Morty Smith")
            #expect(viewModel.characters[1].status == "Alive")
        }
    }


    @Test("State Transition: idle → loading → error", .tags(.stateTransition))
    func testStateTransitionIdleToLoadingToError() async throws {
        // GIVEN: Mock configured to throw an error
        let testError = NetworkError.noConnection
        mockUseCase.mockError = testError

        await MainActor.run {
            #expect(viewModel.isLoading == false)
            #expect(viewModel.error == nil)
        }

        // WHEN: Character loading is executed
        await viewModel.loadCharacters()

        // THEN: The state should be error
        await MainActor.run {
            #expect(viewModel.isLoading == false)
            #expect(viewModel.error != nil)
            #expect(viewModel.characters.isEmpty == true)
        }
    }

    // MARK: - Search Tests

    @Test("Search: Valid text executes search", .tags(.search))
    func testSearchWithValidText() async throws {
        // GIVEN: Mock configured with characters that match the search
        let mockCharacters = [
            MockGetCharactersUseCase.createSimpleMockCharacter(id: 1, name: "Rick Sanchez"),
            MockGetCharactersUseCase.createSimpleMockCharacter(id: 2, name: "Rick Grimes")
        ]
        mockUseCase.mockResponse = MockGetCharactersUseCase.createMockResponse(
            characters: mockCharacters
        )

        // WHEN: The user types search text
        await MainActor.run {
            viewModel.searchText = "rick"
        }

        try await Task.sleep(for: .milliseconds(500))

        // THEN: The UseCase with the search text must have been called

        await MainActor.run {
            let hasRickGrimes = viewModel.characters.contains { $0.name == "Rick Grimes" }

            #expect(mockUseCase.invokeCount > 0)
            #expect(mockUseCase.invokedName == "rick")
            #expect(viewModel.characters.count == 2)
            #expect(hasRickGrimes)
        }
    }

    /// Search test with empty text: does not execute search
    @Test("Search: Empty text does not execute search", .tags(.search))
    func testSearchWithEmptyText() async throws {
        // GIVEN: Initial ViewModel with no previous searches
        mockUseCase.mockResponse = MockGetCharactersUseCase.createMockResponse(
            characters: []
        )

        // WHEN: The user types only spaces
        await MainActor.run {
            viewModel.searchText = "   "
        }

        // Wait for debounce
        try await Task.sleep(for: .milliseconds(500))

        // THEN: The UseCase must not have been called
        #expect(mockUseCase.invokeCount == 0)
    }


    @Test("Search: debounce cancels previous searches", .tags(.search))
    func testSearchDebounceCancelsPrevious() async throws {
        // GIVEN: Mock configured
        mockUseCase.mockResponse = MockGetCharactersUseCase.createMockResponse(
            characters: [MockGetCharactersUseCase.createSimpleMockCharacter(id: 1, name: "Rick")]
        )

        // WHEN: The user quickly types "r", "ri", "ric", "rick"
        await MainActor.run {
            viewModel.searchText = "r"
        }
        try await Task.sleep(for: .milliseconds(100))

        await MainActor.run {
            viewModel.searchText = "ri"
        }
        try await Task.sleep(for: .milliseconds(100))

        await MainActor.run {
            viewModel.searchText = "ric"
        }
        try await Task.sleep(for: .milliseconds(100))

        await MainActor.run {
            viewModel.searchText = "rick"
        }

        // Wait for it to complete the final debounce
        try await Task.sleep(for: .milliseconds(500))

        #expect(mockUseCase.invokedName == "rick")
    }

    /// Search test: does not run if the value has not changed
    @Test("Search: same value does not execute search", .tags(.search))
    func testSearchSameValueDoesNotTrigger() async throws {
        // GIVEN: ViewModel with previous search
        await MainActor.run {
            viewModel.searchText = "rick"
        }
        try await Task.sleep(for: .milliseconds(500))

        let previousInvokeCount = mockUseCase.invokeCount

        // WHEN: The same value is assigned
        await MainActor.run {
            viewModel.searchText = "rick"
        }
        try await Task.sleep(for: .milliseconds(500))

        // THEN: You must not increase the call counter
        #expect(mockUseCase.invokeCount == previousInvokeCount)
    }

    // MARK: - Filter Tests

    @Test("Filter: Select Alive status", .tags(.filter))
    func testFilterByAliveStatus() async throws {
        // GIVEN: Mock set up with live actors
        let mockCharacters = [
            MockGetCharactersUseCase.createSimpleMockCharacter(id: 1, name: "Rick", status: "Alive"),
            MockGetCharactersUseCase.createSimpleMockCharacter(id: 2, name: "Morty", status: "Alive")
        ]
        mockUseCase.mockResponse = MockGetCharactersUseCase.createMockResponse(
            characters: mockCharacters
        )

        // WHEN: The user selects the Alive filter.
        await MainActor.run {
            viewModel.selectedStatus = .alive
        }

        try await Task.sleep(for: .milliseconds(100))

        // THEN: You must have called the UseCase with the status "alive"
        #expect(mockUseCase.invokeCount > 0)
        #expect(mockUseCase.invokedStatus == "alive")
    }

    /// Status filter test: Dead
    @Test("Filter: select Dead status", .tags(.filter))
    func testFilterByDeadStatus() async throws {
        // GIVEN: Mock configured with dead characters
        let mockCharacters = [
            MockGetCharactersUseCase.createSimpleMockCharacter(id: 1, name: "Dead Rick", status: "Dead")
        ]
        mockUseCase.mockResponse = MockGetCharactersUseCase.createMockResponse(
            characters: mockCharacters
        )

        await MainActor.run {
            viewModel.selectedStatus = .dead
        }

        try await Task.sleep(for: .milliseconds(100))

        // THEN: UseCase should be called with status "dead"
        #expect(mockUseCase.invokedStatus == "dead")
    }

    @Test("Filter: selecting All removes filter", .tags(.filter))
    func testFilterByAllRemovesFilter() async throws {
        // GIVEN: ViewModel with a previous filter
        await MainActor.run {
            viewModel.selectedStatus = .alive
        }
        try await Task.sleep(for: .milliseconds(100))

        // WHEN: User selects All
        await MainActor.run {
            viewModel.selectedStatus = .all
        }

        try await Task.sleep(for: .milliseconds(100))

        // THEN: UseCase should be called without status (nil)
        #expect(mockUseCase.invokedStatus == nil)
    }

    // MARK: - Combined Search and Filter Tests

    @Test("Search and Filter: combination of both", .tags(.search, .filter))
    func testSearchAndFilterCombined() async throws {
        // GIVEN: Configured mock
        let mockCharacters = [
            MockGetCharactersUseCase.createSimpleMockCharacter(id: 1, name: "Rick", status: "Alive")
        ]
        mockUseCase.mockResponse = MockGetCharactersUseCase.createMockResponse(
            characters: mockCharacters
        )

        // WHEN: User types text and selects a filter
        await MainActor.run {
            viewModel.searchText = "rick"
            viewModel.selectedStatus = .alive
        }

        try await Task.sleep(for: .milliseconds(500))

        // THEN: UseCase should be called with both parameters
        #expect(mockUseCase.invokedName == "rick")
        #expect(mockUseCase.invokedStatus == "alive")
    }

    // MARK: - Pagination Reset Tests


    @Test("Pagination reset: search change resets to page 1", .tags(.search))
    func testSearchChangeResetsToPageOne() async throws {
        // GIVEN: ViewModel with previous search, characters loaded, and on page 2
        let initialCharacters = [
            MockGetCharactersUseCase.createSimpleMockCharacter(id: 1, name: "Rick"),
            MockGetCharactersUseCase.createSimpleMockCharacter(id: 2, name: "Morty")
        ]
        mockUseCase.mockResponse = MockGetCharactersUseCase.createMockResponse(
            characters: initialCharacters
        )

        await MainActor.run {
            viewModel.searchText = "rick"
        }
        try await Task.sleep(for: .milliseconds(500))

        await MainActor.run {
            viewModel.currentPage = 2
        }

        await MainActor.run {
            #expect(viewModel.currentPage == 2)
            #expect(viewModel.characters.count == 2)
        }

        // WHEN: User changes the search text
        let newCharacters = [
            MockGetCharactersUseCase.createSimpleMockCharacter(id: 3, name: "Summer")
        ]
        mockUseCase.mockResponse = MockGetCharactersUseCase.createMockResponse(
            characters: newCharacters
        )

        await MainActor.run {
            viewModel.searchText = "summer"
        }

        try await Task.sleep(for: .milliseconds(500))

        // THEN: Should be on page 1, list cleared, and only new characters present
        await MainActor.run {
            #expect(viewModel.currentPage == 1)
            #expect(viewModel.characters.count == 1)
            #expect(viewModel.characters[0].name == "Summer")
        }
        #expect(mockUseCase.invokedPage == 1)
    }

    @Test("Pagination reset: filter change resets to page 1", .tags(.filter))
    func testFilterChangeResetsToPageOne() async throws {
        // GIVEN: ViewModel with characters loaded and on page 2
        let initialCharacters = [
            MockGetCharactersUseCase.createSimpleMockCharacter(id: 1, name: "Rick", status: "Alive")
        ]
        mockUseCase.mockResponse = MockGetCharactersUseCase.createMockResponse(
            characters: initialCharacters
        )

        await viewModel.loadCharacters()

        await MainActor.run {
            viewModel.currentPage = 2
        }

        await MainActor.run {
            #expect(viewModel.currentPage == 2)
            #expect(viewModel.characters.count == 1)
        }

        // WHEN: User changes the filter
        let newCharacters = [
            MockGetCharactersUseCase.createSimpleMockCharacter(id: 2, name: "Dead Rick", status: "Dead")
        ]
        mockUseCase.mockResponse = MockGetCharactersUseCase.createMockResponse(
            characters: newCharacters
        )

        await MainActor.run {
            viewModel.selectedStatus = .dead
        }

        // Wait for execution
        try await Task.sleep(for: .milliseconds(100))

        // THEN: Should be on page 1, list cleared, and only new characters present
        await MainActor.run {
            #expect(viewModel.currentPage == 1)
            #expect(viewModel.characters.count == 1)
            #expect(viewModel.characters[0].name == "Dead Rick")
            #expect(viewModel.characters[0].status == "Dead")
        }
        #expect(mockUseCase.invokedPage == 1)
    }
}
