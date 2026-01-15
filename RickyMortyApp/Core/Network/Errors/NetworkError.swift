//
//  NetworkError.swift
//  RickyMortyApp
//
//  Created by Angelber Castro on 1/12/26.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case unauthorized
    case decodingFailed
    case noConnection
    case timeout
    case serverError(code: Int)
    case serverErrorWithMessage(code: Int, message: String, errorCode: String)
    case underlying(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .unauthorized:
            return "Unauthorized. Please log in again."
        case .decodingFailed:
            return "Failed to decode server response."
        case .noConnection:
            return "There is no internet connection. Please check your connection."
        case .timeout:
            return "The request took too long. Please try again."
        case .serverError(let code):
            return "The server responded with code: \(code)"
        case .serverErrorWithMessage(_, let message, _):
            return message
        case .underlying(let error):
            return error.localizedDescription
        }
    }
}

struct ErrorResponse: Codable {
    let error: String
    let code: String
}

