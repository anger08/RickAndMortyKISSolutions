//
//  NetworkServiceTests.swift
//  RickyMortyAppTests
//
//  Created by Angelber Castro on 1/14/26.
//

import Testing
import Foundation
@testable import RickyMortyApp

extension Tag {
    @Tag static var networkService: Self
    @Tag static var decoding: Self
    @Tag static var api: Self
}

@Suite("NetworkService Tests - Successful Decoding", .tags(.networkService, .decoding, .api))
struct NetworkServiceTests {

    // MARK: - Test: Successful decoding of CharactersResponse

    @Test("Successful decoding: CharactersResponse with multiple characters", .tags(.decoding))
    func testSuccessfulDecodingCharactersResponse() async throws {
        // GIVEN: Valid JSON with a complete CharactersResponse structure
        let testURL = URL(string: "https://rickandmortyapi.com/api/character")!

        let jsonData = TestJSONHelper.createCharactersResponseJSON(
            count: 826,
            pages: 42,
            next: "https://rickandmortyapi.com/api/character?page=2",
            prev: nil
        )
        let httpResponse = TestJSONHelper.createHTTPResponse(statusCode: 200, url: testURL)

        let mockSession = MockURLSessionProtocol()
        mockSession.mockData = jsonData
        mockSession.mockResponse = httpResponse

        let networkService = await NetworkService(session: mockSession)

        // WHEN: Request and decoding are performed
        let response: CharactersResponse = try await networkService.fetchDecodable(
            from: testURL,
            method: .get,
            headers: nil
        )

        // THEN: The response should be correctly decoded
        await MainActor.run {
            #expect(response.info.count == 826)
            #expect(response.info.pages == 42)
            #expect(response.info.next == "https://rickandmortyapi.com/api/character?page=2")
            #expect(response.info.prev == nil)
            #expect(response.results.count == 2)
            #expect(response.results[0].id == 1)
            #expect(response.results[0].name == "Rick Sanchez")
            #expect(response.results[0].status == "Alive")
            #expect(response.results[0].species == "Human")
            #expect(response.results[0].gender == "Male")
            #expect(response.results[1].id == 2)
            #expect(response.results[1].name == "Morty Smith")
        }

    }

    @Test("Successful decoding: CharactersResponse with snake_case to camelCase conversion", .tags(.decoding))
    func testSnakeCaseToCamelCaseConversion() async throws {
        // GIVEN: JSON with snake_case that should be converted to camelCase
        let testURL = URL(string: "https://rickandmortyapi.com/api/character")!

        // Create JSON with explicit snake_case keys
        let jsonData = TestJSONHelper.createCharactersResponseJSON(
            count: 100,
            pages: 5,
            next: nil,
            prev: nil
        )
        let httpResponse = TestJSONHelper.createHTTPResponse(statusCode: 200, url: testURL)

        let mockSession = MockURLSessionProtocol()
        mockSession.mockData = jsonData
        mockSession.mockResponse = httpResponse

        let networkService = await NetworkService(session: mockSession)

        // WHEN: The response is decoded
        let response: CharactersResponse = try await networkService.fetchDecodable(
            from: testURL,
            method: .get,
            headers: nil
        )

        // THEN: Fields should be correctly mapped (the decoder uses convertFromSnakeCase)
        await MainActor.run {
            #expect(response.info.count == 100)
            #expect(response.info.pages == 5)
            // Verify that nested fields are also decoded correctly
            #expect(response.results[0].origin.name == "Earth (C-137)")
            #expect(response.results[0].location.name == "Citadel of Ricks")
        }

    }

    @Test("Successful decoding: Empty CharactersResponse (no results)", .tags(.decoding))
    func testSuccessfulDecodingEmptyCharactersResponse() async throws {
        // GIVEN: JSON with an empty results list
        let testURL = URL(string: "https://rickandmortyapi.com/api/character")!
        let jsonData = TestJSONHelper.createCharactersResponseJSON(
            count: 0,
            pages: 0,
            next: nil,
            prev: nil,
            characters: []
        )
        let httpResponse = TestJSONHelper.createHTTPResponse(statusCode: 200, url: testURL)

        let mockSession = MockURLSessionProtocol()
        mockSession.mockData = jsonData
        mockSession.mockResponse = httpResponse

        let networkService = await NetworkService(session: mockSession)

        // WHEN: The response is decoded
        let response: CharactersResponse = try await networkService.fetchDecodable(
            from: testURL,
            method: .get,
            headers: nil
        )
        await MainActor.run {
            // THEN: The response should have an empty list but a valid structure
            #expect(response.info.count == 0)
            #expect(response.info.pages == 0)
            #expect(response.results.isEmpty == true)
        }

    }


    // MARK: - Test: Decoding with different successful HTTP states

    @Test("Successful decoding: HTTP 201 Created response", .tags(.decoding, .api))
    func testSuccessfulDecodingWith201StatusCode() async throws {
        // GIVEN: HTTP 201 response (within the 200-299 range)
        let testURL = URL(string: "https://rickandmortyapi.com/api/character")!
        let jsonData = TestJSONHelper.createCharactersResponseJSON()
        let httpResponse = TestJSONHelper.createHTTPResponse(statusCode: 201, url: testURL)

        let mockSession = MockURLSessionProtocol()
        mockSession.mockData = jsonData
        mockSession.mockResponse = httpResponse

        let networkService = await NetworkService(session: mockSession)

        // WHEN: Request is performed
        let response: CharactersResponse = try await networkService.fetchDecodable(
            from: testURL,
            method: .get,
            headers: nil
        )

        // THEN: Decoding should be successful
        #expect(response.results.count == 2)
    }

    @Test("Successful decoding: HTTP 204 No Content response with data", .tags(.decoding, .api))
    func testSuccessfulDecodingWith204StatusCode() async throws {
        // GIVEN: HTTP 204 response (within the 200-299 range)
        let testURL = URL(string: "https://rickandmortyapi.com/api/character")!
        let jsonData = TestJSONHelper.createCharactersResponseJSON()
        let httpResponse = TestJSONHelper.createHTTPResponse(statusCode: 204, url: testURL)

        let mockSession = MockURLSessionProtocol()
        mockSession.mockData = jsonData
        mockSession.mockResponse = httpResponse

        let networkService = await NetworkService(session: mockSession)

        // WHEN: Request is performed
        let response: CharactersResponse = try await networkService.fetchDecodable(
            from: testURL,
            method: .get,
            headers: nil
        )

        // THEN: Decoding should be successful
        #expect(response.results.count == 2)
    }
}
