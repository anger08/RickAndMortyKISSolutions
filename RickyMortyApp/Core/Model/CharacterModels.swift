//
//  CharacterModels.swift
//  RickyMortyApp
//
//  Created by Angelber Castro on 1/12/26.
//

import Foundation

// MARK: - CharactersResponse
nonisolated struct CharactersResponse: Codable {
    let info: Info
    let results: [Character]
}

// MARK: - Info
nonisolated struct Info: Codable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}

// MARK: - Character
nonisolated struct Character: Codable, Identifiable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String
    let gender: String
    let origin: Location
    let location: Location
    let image: String
    let episode: [String]
    let url: String
    let created: String
}

// MARK: - Location
nonisolated struct Location: Codable {
    let name: String
    let url: String
}


