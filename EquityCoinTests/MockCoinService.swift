//
//  MockCoinService.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 06/03/25.
//

import Foundation
@testable import EquityCoin

class MockCoinService: EBCoinServiceProtocol {
    var mockCoins: [EBCoin] = []
    var mockHistory: [EBCoinHistory] = []
    
    func fetchCoins(page: Int, limit: Int) async throws -> [EBCoin] {
        return mockCoins
    }
    
    func fetchCoinHistory(coinId: String, timePeriod: String) async throws -> [EBCoinHistory] {
        return mockHistory
    }
}
