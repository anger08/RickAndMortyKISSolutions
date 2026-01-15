//
//  URLDomains.swift
//  RickyMortyApp
//
//  Created by Angelber Castro on 1/12/26.
//

import Foundation

final class URLDomains: @unchecked Sendable {
    static let shared = URLDomains()
    
    let BASE_URL = "https://rickandmortyapi.com/api/"
    
    let endpointCharacters = "character"
}
