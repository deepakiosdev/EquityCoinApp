//
//  EBNetworkError.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 26/02/25.
//

import Foundation

enum EBNetworkError: Error {
    case noInternet
    case timeout
    case serverError(statusCode: Int)
    case decodingFailed(description: String)
    case networkError(description: String)
    case unknown(description: String)
    case invalidURL
    
    var localizedDescription: String {
        switch self {
        case .noInternet: return "No internet connection available."
        case .timeout: return "Request timed out. Please try again."
        case .serverError(let statusCode): return "Server error with status code: \(statusCode)"
        case .decodingFailed(let description): return "Failed to parse response: \(description)"
        case .networkError(let description): return "Network error: \(description)"
        case .unknown(let description): return "Unknown error: \(description)"
        case .invalidURL: return "Invalid URL provided."
        }
    }
}
