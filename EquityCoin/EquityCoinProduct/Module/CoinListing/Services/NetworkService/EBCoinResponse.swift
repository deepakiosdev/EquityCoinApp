//
//  EBCoinResponse.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 26/02/25.
//

import Foundation

struct EBCoinResponse: Codable {
    let status: String
    let data: EBCoinData
}

struct EBCoinData: Codable {
    let coins: [EBCoin]
    
    enum CodingKeys: String, CodingKey {
        case coins
    }
}
