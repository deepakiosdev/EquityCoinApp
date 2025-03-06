//
//  EBCoinServiceProtocol.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 26/02/25.
//

import Foundation

protocol EBCoinServiceProtocol {
    func fetchCoins(page: Int, limit: Int) async throws -> [EBCoin]
    func fetchCoinHistory(coinId: String, timePeriod: String) async throws -> [EBCoinHistory]
}
