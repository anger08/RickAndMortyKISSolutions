//
//  GetCharactersUseCaseImpl.swift
//  RickyMortyApp
//
//  Created by Angelber Castro on 1/14/26.
//

import Factory

final class GetCharactersUseCaseImpl: GetCharactersUseCase {
    @Injected(\.homeRepository) private var repo: HomeRepository

    nonisolated init() {}

    func invoke(page: Int, name: String?, status: String?) async throws -> CharactersResponse {
        return try await repo.getCharacters(page: page, name: name, status: status)
    }
}
