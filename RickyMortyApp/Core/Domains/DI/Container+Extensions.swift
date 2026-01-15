//
//  Container+Extensions.swift
//  RickyMortyApp
//
//  Created by Angelber Castro on 1/12/26.
//

import Factory

extension Container {
    var getCharactersUseCase: Factory<GetCharactersUseCase> {
        Factory(self) { GetCharactersUseCaseImpl() as GetCharactersUseCase }
    }
    
    var getCharacterUseCase: Factory<GetCharacterUseCase> {
        Factory(self) { GetCharacterUseCaseImpl() as GetCharacterUseCase }
    }
}
