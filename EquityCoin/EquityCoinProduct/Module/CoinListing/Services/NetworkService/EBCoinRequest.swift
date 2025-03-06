//
//  EBCoinRequest.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 26/02/25.
//

import Foundation

struct EBCoinRequest: EBRequestable {
    let baseURL = EBAPIConstants.baseURL
    let path: String
    var queryParameters: [String: String]?
    
    var method: EBHTTPMethod { .get }
    
    var headers: [String: String]? {
        guard let apiKey = EBAPISecurity.getAPIKey() else {
            return nil
        }
        return [EBAPIConstants.keyHeaderToken : apiKey]
    }
    
    var url: URL? {
        var components = URLComponents(string: baseURL)
        components?.path = path
        if let queryParameters = queryParameters {
            components?.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        return components?.url
    }
}
