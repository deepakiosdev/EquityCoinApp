//
//  EBCoin.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 26/02/25.
//

import Foundation

/// Represents a cryptocurrency with its details from the CoinRanking API, handling missing or null values with custom decoding.
struct EBCoin: Codable, Identifiable, Equatable {
    
    init(id: String,
         name: String,
         symbol: String,
         iconUrl: String? = nil,
         price: String,
         change: String,
         rank: Int? = nil,
         volume24h: String? = nil,
         marketCap: String? = nil,
         listedAt: Int? = nil,
         btcPrice: String? = nil,
         sparkline: [String]) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.iconUrl = iconUrl
        self.price = price
        self.change = change
        self.rank = rank
        self.volume24h = volume24h
        self.marketCap = marketCap
        self.listedAt = listedAt
        self.btcPrice = btcPrice
        self.sparkline = sparkline
    }
    
    let id: String
    let name: String
    let symbol: String
    let iconUrl: String?
    let price: String
    let change: String
    let rank: Int?
    let volume24h: String?
    let marketCap: String?
    let listedAt: Int? // Unix timestamp for listing date
    let btcPrice: String?
    let sparkline: [String]
    
    var priceDouble: Double { Double(price) ?? 0.0 }
    var changeDouble: Double { Double(change) ?? 0.0 }
    var sparklineDoubles: [Double] { sparkline.compactMap { Double($0) ?? 0.0 } }
    
    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case name
        case symbol
        case iconUrl
        case price
        case change
        case rank
        case volume24h = "24hVolume"
        case marketCap
        case listedAt
        case btcPrice
        case sparkline
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle required fields with fallback or error
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? "unknown"
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Unknown Coin"
        symbol = try container.decodeIfPresent(String.self, forKey: .symbol) ?? "UNK"
        price = try container.decodeIfPresent(String.self, forKey: .price) ?? "0.0"
        change = try container.decodeIfPresent(String.self, forKey: .change) ?? "0.0"
        
        // Handle optional fields with nil if missing
        iconUrl = try container.decodeIfPresent(String.self, forKey: .iconUrl)
        rank = try container.decodeIfPresent(Int.self, forKey: .rank)
        volume24h = try container.decodeIfPresent(String.self, forKey: .volume24h)
        marketCap = try container.decodeIfPresent(String.self, forKey: .marketCap)
        listedAt = try container.decodeIfPresent(Int.self, forKey: .listedAt)
        btcPrice = try container.decodeIfPresent(String.self, forKey: .btcPrice)
        
        // Handle sparkline as an array, defaulting to empty if missing or null
        sparkline = try container.decodeIfPresent([String].self, forKey: .sparkline) ?? []
    }
    
    static func ==(lhs: EBCoin, rhs: EBCoin) -> Bool {
        lhs.id == rhs.id
    }
}

// Helper extension to convert EBCoinModel to EBCoin
extension EBCoin {
    init(from ebcoinModel: EBCoinModel) {
        self.id = ebcoinModel.id
        self.name = ebcoinModel.name
        self.symbol = ebcoinModel.symbol
        self.iconUrl = ebcoinModel.iconUrl
        self.price = ebcoinModel.price
        self.change = ebcoinModel.change
        self.rank = ebcoinModel.rank
        self.volume24h = ebcoinModel.volume24h
        self.marketCap = ebcoinModel.marketCap
        self.listedAt = ebcoinModel.listedAt
        self.btcPrice = ebcoinModel.btcPrice
        self.sparkline = ebcoinModel.sparkline
    }
}
