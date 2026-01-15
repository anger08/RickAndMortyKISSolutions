//
//  MockGetCharactersUseCase.swift
//  RickyMortyAppTests
//
//  Created by Angelber Castro on 1/14/26.
//

import Foundation
@testable import RickyMortyApp

final class MockGetCharactersUseCase: GetCharactersUseCase {
    var mockResponse: CharactersResponse?

    // Mock error to be thrown (if configured)
    var mockError: Error?

    var invokedPage: Int?
    var invokedName: String?
    var invokedStatus: String?
    var invokeCount: Int = 0

    func invoke(page: Int, name: String? = nil, status: String? = nil) async throws -> CharactersResponse {
        invokeCount += 1
        invokedPage = page
        invokedName = name
        invokedStatus = status

        if let error = mockError {
            throw error
        }

        if let response = mockResponse {
            return response
        }

        return CharactersResponse(
            info: Info(count: 0, pages: 0, next: nil, prev: nil),
            results: []
        )
    }

    /// Helper to create a mocked CharactersResponse
    static func createMockResponse(
        characters: [Character],
        hasNextPage: Bool = false,
        currentPage: Int = 1
    ) -> CharactersResponse {
        return CharactersResponse(
            info: Info(
                count: characters.count,
                pages: hasNextPage ? currentPage + 1 : currentPage,
                next: hasNextPage ? "next_page" : nil,
                prev: currentPage > 1 ? "prev_page" : nil
            ),
            results: characters
        )
    }

    /// Factory method to create a Character with full details
    static func createMockCharacter(
        id: Int,
        name: String,
        status: String = "Alive",
        species: String = "Human",
        type: String = "",
        gender: String = "Male",
        originName: String = "Earth",
        originUrl: String = "",
        locationName: String = "Earth",
        locationUrl: String = "",
        image: String = "",
        episode: [String] = [],
        url: String = "",
        created: String = ""
    ) -> Character {
        return Character(
            id: id,
            name: name,
            status: status,
            species: species,
            type: type,
            gender: gender,
            origin: Location(name: originName, url: originUrl),
            location: Location(name: locationName, url: locationUrl),
            image: image,
            episode: episode,
            url: url,
            created: created
        )
    }

    /// Factory method for a simplified Character (ideal for basic filtering/search tests)
    static func createSimpleMockCharacter(
        id: Int,
        name: String,
        status: String = "Alive"
    ) -> Character {
        return createMockCharacter(
            id: id,
            name: name,
            status: status,
            species: "Human",
            type: "",
            gender: "Male",
            originName: "Earth",
            locationName: "Earth"
        )
    }
}
