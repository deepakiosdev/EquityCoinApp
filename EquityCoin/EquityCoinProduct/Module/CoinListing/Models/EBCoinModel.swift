//
//  EBCoinModel.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 01/03/25.
//

struct EBCoinModel {
    internal init(id: String, name: String, symbol: String, iconUrl: String? = nil, price: String, change: String, rank: Int? = nil, volume24h: String? = nil, marketCap: String? = nil, listedAt: Int? = nil, btcPrice: String? = nil, sparkline: [String]) {
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
    
    init(from ebcoin: EBCoin) {
        self.id = ebcoin.id
        self.name = ebcoin.name
        self.symbol = ebcoin.symbol
        self.iconUrl = ebcoin.iconUrl
        self.price = ebcoin.price
        self.change = ebcoin.change
        self.rank = ebcoin.rank
        self.volume24h = ebcoin.volume24h
        self.marketCap = ebcoin.marketCap
        self.listedAt = ebcoin.listedAt
        self.btcPrice = ebcoin.btcPrice
        self.sparkline = ebcoin.sparkline
    }
}
