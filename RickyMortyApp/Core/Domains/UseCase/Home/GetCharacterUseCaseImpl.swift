//
//  GetCharacterUseCaseImpl.swift
//  RickyMortyApp
//
//  Created by Angelber Castro on 1/14/26.
//

import Factory

final class GetCharacterUseCaseImpl: GetCharacterUseCase {
    @Injected(\.homeRepository) private var repo: HomeRepository

    nonisolated init() {}

    func invoke(id: Int) async throws -> Character {
        return try await repo.getCharacter(id: id)
    }
}
