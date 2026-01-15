//
//  GetCharacterUseCase.swift
//  RickyMortyApp
//
//  Created by Angelber Castro on 1/12/26.
//

protocol GetCharacterUseCase {
    func invoke(id: Int) async throws -> Character
}
