//
//  TestJSONHelper.swift
//  RickyMortyAppTests
//
//  Created by Angelber Castro on 1/14/26.
//

import Foundation

// MARK: - Helper to create test JSON
struct TestJSONHelper {
    static func createCharactersResponseJSON(
        count: Int = 826,
        pages: Int = 42,
        next: String? = "https://rickandmortyapi.com/api/character?page=2",
        prev: String? = nil,
        characters: [[String: Any]]? = nil
    ) -> Data {
        let defaultCharacters: [[String: Any]] = [
            [
                "id": 1,
                "name": "Rick Sanchez",
                "status": "Alive",
                "species": "Human",
                "type": "",
                "gender": "Male",
                "origin": ["name": "Earth (C-137)", "url": "https://rickandmortyapi.com/api/location/1"],
                "location": ["name": "Citadel of Ricks", "url": "https://rickandmortyapi.com/api/location/3"],
                "image": "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
                "episode": ["https://rickandmortyapi.com/api/episode/1"],
                "url": "https://rickandmortyapi.com/api/character/1",
                "created": "2017-11-04T18:48:46.250Z"
            ],
            [
                "id": 2,
                "name": "Morty Smith",
                "status": "Alive",
                "species": "Human",
                "type": "",
                "gender": "Male",
                "origin": ["name": "unknown", "url": ""],
                "location": ["name": "Citadel of Ricks", "url": "https://rickandmortyapi.com/api/location/3"],
                "image": "https://rickandmortyapi.com/api/character/avatar/2.jpeg",
                "episode": ["https://rickandmortyapi.com/api/episode/1"],
                "url": "https://rickandmortyapi.com/api/character/2",
                "created": "2017-11-04T18:50:21.651Z"
            ]
        ]
        
        let finalCharacters = characters ?? defaultCharacters
        
        let json: [String: Any] = [
            "info": [
                "count": count,
                "pages": pages,
                "next": next as Any,
                "prev": prev as Any
            ],
            "results": finalCharacters
        ]
        
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    static func createCharacterJSON(
        id: Int = 1,
        name: String = "Rick Sanchez",
        status: String = "Alive",
        species: String = "Human",
        type: String = "",
        gender: String = "Male",
        originName: String = "Earth (C-137)",
        originUrl: String = "https://rickandmortyapi.com/api/location/1",
        locationName: String = "Citadel of Ricks",
        locationUrl: String = "https://rickandmortyapi.com/api/location/3",
        image: String = "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
        episode: [String] = ["https://rickandmortyapi.com/api/episode/1"],
        url: String = "https://rickandmortyapi.com/api/character/1",
        created: String = "2017-11-04T18:48:46.250Z"
    ) -> Data {
        let json: [String: Any] = [
            "id": id,
            "name": name,
            "status": status,
            "species": species,
            "type": type,
            "gender": gender,
            "origin": ["name": originName, "url": originUrl],
            "location": ["name": locationName, "url": locationUrl],
            "image": image,
            "episode": episode,
            "url": url,
            "created": created
        ]
        
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    static func createHTTPResponse(statusCode: Int = 200, url: URL) -> HTTPURLResponse {
        return HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!
    }
}

