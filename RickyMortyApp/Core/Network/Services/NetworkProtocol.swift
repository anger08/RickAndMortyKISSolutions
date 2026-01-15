//
//  NetworkProtocol.swift
//  RickyMortyApp
//
//  Created by Angelber Castro on 1/12/26.
//

import Foundation

protocol NetworkProtocol  {
    func fetchDecodable<T: Decodable>(
        from url: URL,
        method: HTTPMethod,
        headers: HTTPHeaders?
    ) async throws(NetworkError) -> T
}
