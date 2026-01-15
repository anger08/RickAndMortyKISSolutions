//
//  HomeRepository.swift
//  RickyMortyApp
//
//  Created by Angelber Castro on 1/12/26.
//

protocol HomeRepository {
    func getCharacters(page: Int, name: String?, status: String?) async throws(NetworkError) -> CharactersResponse
    func getCharacter(id: Int) async throws(NetworkError) -> Character
}
