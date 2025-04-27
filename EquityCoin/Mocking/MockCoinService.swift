//
//  MockCoinService.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 06/03/25.
//

import Foundation

class MockCoinService: EBCoinServiceProtocol {
    var mockCoins: [EBCoin] = []
    var mockHistory: [EBCoinHistory] = []
    
    init() {
        // Load mock data when initializing the service
        if let response: EBCoinResponse = MockDataFetchable.loadMockData(fileName: "CoinList") {
            self.mockCoins = response.data.coins
        }
        //self.mockHistory = MockDataFetchable.loadMockData(fileName: "history") ?? []
    }
    
    func fetchCoins(page: Int, limit: Int) async throws -> [EBCoin] {
        return mockCoins
    }
    
    func fetchCoinHistory(coinId: String, timePeriod: String) async throws -> [EBCoinHistory] {
        return mockHistory
    }
}
