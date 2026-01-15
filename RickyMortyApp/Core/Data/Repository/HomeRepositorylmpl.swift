//
//  HomeRepositorylmpl.swift
//  RickyMortyApp
//
//  Created by Angelber Castro on 1/12/26.
//

import Factory

final class HomeRepositorylmpl: HomeRepository {
    @Injected(\.homeRemoteDataSource) private var remote: HomeRemoteDtaSource
    
    nonisolated init() {}
    
    /// SEARCH AND FILTERING: Direct delegation to the remote data source.
    func getCharacters(page: Int, name: String?, status: String?) async throws(NetworkError) -> CharactersResponse {
        return try await remote.getCharacters(page: page, name: name, status: status)
    }

    func getCharacter(id: Int) async throws(NetworkError) -> Character {
        return try await remote.getCharacter(id: id)
    }
}
