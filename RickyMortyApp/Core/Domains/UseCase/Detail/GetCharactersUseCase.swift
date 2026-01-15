//
//  GetCharactersUseCase.swift
//  RickyMortyApp
//
//  Created by Angelber Castro on 1/12/26.
//

import Factory

protocol GetCharactersUseCase {
    func invoke(page: Int, name: String?, status: String?) async throws -> CharactersResponse
}
