//
//  EBCoinHistory.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 26/02/25.
//

import Foundation

struct EBCoinHistoryResponse: Codable {
    let status: String
    let data: EBCoinHistoryData
}

struct EBCoinHistoryData: Codable {
    let change: String?
    let history: [EBCoinHistory]
}

/// Represents historical price data for a cryptocurrency from the CoinRanking API, handling missing or null values with custom decoding.
struct EBCoinHistory: Codable, Equatable {
    
    init(price: String, timestamp: Int) {
        self.price = price
        self.timestamp = timestamp
    }
    
    let price: String
    let timestamp: Int
    
    var priceDouble: Double { Double(price) ?? 0.0 }
    var date: Date { Date(timeIntervalSince1970: TimeInterval(timestamp)) }
    
    enum CodingKeys: String, CodingKey {
        case price
        case timestamp
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle required fields with fallback or error
        price = try container.decodeIfPresent(String.self, forKey: .price) ?? "0.0"
        timestamp = try container.decodeIfPresent(Int.self, forKey: .timestamp) ?? 0
    }
    
    static func ==(lhs: EBCoinHistory, rhs: EBCoinHistory) -> Bool {
        lhs.timestamp == rhs.timestamp && lhs.price == rhs.price
    }
}
