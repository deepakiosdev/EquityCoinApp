//
//  EBNetworkService.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 26/02/25.
//

import Foundation

/// Defines the network service protocol for performing HTTP requests
protocol EBNetworkService {
    func performRequest(_ request: EBRequestable) async throws -> (Data, URLResponse)
}

final class EBNetworkManager: EBNetworkService {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func performRequest(_ request: EBRequestable) async throws -> (Data, URLResponse) {
        guard let url = request.url else {
            throw EBNetworkError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headers
        
        if let queryParameters = request.queryParameters {
            urlRequest.url = url.appendingQueryParameters(queryParameters)
        }
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            debugPrint("Network response for \(url): \(response)")
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw EBNetworkError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
            }
            return (data, response)
        } catch {
            throw handleNetworkError(error)
        }
    }
    
    private func handleNetworkError(_ error: Error) -> EBNetworkError {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return EBNetworkError.noInternet
            case .timedOut:
                return EBNetworkError.timeout
            default:
                return EBNetworkError.networkError(description: urlError.localizedDescription)
            }
        }
        return EBNetworkError.unknown(description: error.localizedDescription)
    }
}

extension URL {
    func appendingQueryParameters(_ parameters: [String: String]) -> URL? {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else { return nil }
        components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        return components.url
    }
}
