//
//  HomeRemoteDtaSourcelmpl.swift
//  RickyMortyApp
//
//  Created by Angelber Castro on 1/12/26.
//

import Foundation
import Factory

final class HomeRemoteDtaSourcelmpl: HomeRemoteDtaSource {
    private let networkService: NetworkService
    
     init(networkService: NetworkService = NetworkService()) {
        self.networkService = networkService
    }

    func getCharacters(page: Int, name: String?, status: String?) async throws(NetworkError) -> CharactersResponse {
        guard let url = makeCharactersURL(page: page, name: name, status: status)?.url else {
            throw .invalidURL
        }
        let response: CharactersResponse = try await networkService.fetchDecodable(
            from: url,
            method: .get,
            headers: nil
        )
        return response
    }
    
    /// DETAIL:
    func getCharacter(id: Int) async throws(NetworkError) -> Character {
        guard let url = makeCharacterDetailURL(id: id) else {
            throw .invalidURL
        }

        let character: Character = try await networkService.fetchDecodable(
            from: url,
            method: .get,
            headers: nil
        )
        return character
    }
}

extension HomeRemoteDtaSourcelmpl {
    func makeCharactersURL(page: Int, name: String?, status: String?) -> URLComponents? {
        var components = URLComponents(string: URLDomains.shared.BASE_URL + URLDomains.shared.endpointCharacters)

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        // SEARCH BY NAME: Add parameter only if the text is not empty
        if let name = name, !name.trimmingCharacters(in: .whitespaces).isEmpty {
            queryItems.append(URLQueryItem(name: "name", value: name))
        }
        
        // FILTER BY STATE: Add parameter only if a state is selected
        if let status = status {
            queryItems.append(URLQueryItem(name: "status", value: status))
        }

        components?.queryItems = queryItems
        return components
    }
    func makeCharacterDetailURL(id: Int) -> URL? {
        let urlString = URLDomains.shared.BASE_URL + URLDomains.shared.endpointCharacters + "/\(id)"
        return URL(string: urlString)
    }
}
