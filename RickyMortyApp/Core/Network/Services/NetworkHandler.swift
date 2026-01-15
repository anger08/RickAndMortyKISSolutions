//
//  NetworkResponseHandler.swift
//  RickyMortyApp
//
//  Created by Angelber Castro on 1/12/26.
//

import Foundation

struct NetworkResponseHandler {

    static func handleResponse<T: Decodable>(
        data: Data?,
        response: URLResponse?,
        error: Error?
    ) throws(NetworkError) -> T {
        if let error = error {
            throw handleURLError(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidURL
        }
        
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw handleHTTPError(statusCode: httpResponse.statusCode, data: data)
        }
        
        guard let data = data else {
            throw NetworkError.decodingFailed
        }
        
        return try decodeResponse(data)
    }

    /// Decode the JSON response to the expected type
    private static func decodeResponse<T: Decodable>(_ data: Data) throws(NetworkError) -> T {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            #if DEBUG
            print("Expected type: \(T.self) - Error: \(error)")

            if let jsonString = String(data: data, encoding: .utf8) {
                print("JSON received: \(jsonString)")
            }
            #endif
            throw NetworkError.decodingFailed
        }
    }
    
    /// It handles HTTP errors and converts them to NetworkError.
    private static func handleHTTPError(statusCode: Int, data: Data?) -> NetworkError {
        if statusCode == 401 {
            return .unauthorized
        }
        
        if let data = data {
            // Check if the response is HTML instead of JSON
            if let dataString = String(data: data, encoding: .utf8),
               dataString.contains("<!DOCTYPE html") || dataString.contains("<html") {
                #if DEBUG
                print("The server returned an HTML error page (status: \(statusCode))")
                print("Content HTML: \(dataString)")
                #endif
                return .serverErrorWithMessage(
                    code: statusCode,
                    message: "The server returned an HTML error page",
                    errorCode: "HTML_ERROR"
                )
            }
            
            do {
                let decoder = JSONDecoder()
                let apiError = try decoder.decode(ErrorResponse.self, from: data)
                return .serverErrorWithMessage(
                    code: statusCode,
                    message: apiError.error,
                    errorCode: apiError.code
                )
            } catch {
                #if DEBUG
                if let dataString = String(data: data, encoding: .utf8) {
                    print("The server error could not be decoded (status: \(statusCode)). Content: \(dataString)")
                }
                #endif
            }
        }
        
        return .serverError(code: statusCode)
    }
    
    /// Handles URLSession errors and converts them to NetworkError
    private static func handleURLError(_ error: Error) -> NetworkError {
        let nsError = error as NSError
        
        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorNotConnectedToInternet,
                 NSURLErrorNetworkConnectionLost,
                 NSURLErrorCannotConnectToHost:
                return .noConnection
            case NSURLErrorTimedOut:
                return .timeout
            default:
                return .underlying(error)
            }
        }
        
        return .underlying(error)
    }
}
