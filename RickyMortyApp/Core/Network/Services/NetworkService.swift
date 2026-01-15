
import Foundation

// MARK: - Protocol for URLSession (dependency injection)
protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

typealias HTTPHeaders = [String: String]

struct NetworkService: NetworkProtocol {
    private let session: any URLSessionProtocol

    init(session: any URLSessionProtocol = URLSession.shared) {
        self.session = session
    }

    func fetchDecodable<T: Decodable>(
        from url: URL,
        method: HTTPMethod,
        headers: HTTPHeaders?
    ) async throws(NetworkError) -> T {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        do {
            let (data, response) = try await session.data(for: request)
            return try NetworkResponseHandler.handleResponse(
                data: data,
                response: response,
                error: nil
            )
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.underlying(error)
        }
    }
}
