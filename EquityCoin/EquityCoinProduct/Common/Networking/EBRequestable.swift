//
//  EBRequestable.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 26/02/25.
//

import Foundation

protocol EBRequestable {
    var baseURL: String { get }
    var path: String { get }
    var queryParameters: [String: String]? { get }
    var method: EBHTTPMethod { get }
    var headers: [String: String]? { get }
    var url: URL? { get }
}

enum EBHTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

extension EBRequestable {
    var method: EBHTTPMethod { .get }
    var queryParameters: [String: String]? { nil }
    var headers: [String: String]? { nil }
    
    func asURLRequest() throws -> URLRequest {
        guard var urlComponents = URLComponents(string: baseURL + path) else {
            throw EBNetworkError.invalidURL
        }
        
        if let queryParameters = queryParameters {
            urlComponents.queryItems = queryParameters.map { URLQueryItem(name: $0.key,
                                                                          value: $0.value) }
        }
        
        guard let url = urlComponents.url else { throw EBNetworkError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        headers?.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        return request
    }
}
