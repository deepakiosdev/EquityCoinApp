//
//  EBAPISecurity.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 01/03/25.
//

import Foundation

/// Handles API security and key management for the App.
final class EBAPISecurity {
    private static let apiKeyKey = "coinrankingcf961cf9aa3148fedb3267a37c6d9e02978008a9f13e013c"
    
    static func getAPIKey() -> String? {
        return apiKeyKey
    }
    
    /// Ensures API requests use HTTPS
    static func secureRequest(_ request: inout URLRequest) {
        guard var components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false) else {
            debugPrint("Failed to create URL components for secure request")
            return
        }
        
        // Ensure the scheme is HTTPS
        components.scheme = "https"
        
        if let secureURL = components.url {
            request.url = secureURL
            debugPrint("Secured request with HTTPS URL: \(secureURL)")
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.waitsForConnectivity = true
        } else {
            debugPrint("Failed to create secure URL")
        }
    }
}
