//
//  MockURLSessionProtocol.swift
//  RickyMortyAppTests
//
//  Created by Angelber Castro on 1/14/26.
//

import Foundation
@testable import RickyMortyApp

// MARK: - Mock URLSession para pruebas
final class MockURLSessionProtocol: URLSessionProtocol {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        
        guard let data = mockData, let response = mockResponse else {
            throw NSError(
                domain: "MockURLSession",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Mock data or response not configured"]
            )
        }
        
        return (data, response)
    }
}

