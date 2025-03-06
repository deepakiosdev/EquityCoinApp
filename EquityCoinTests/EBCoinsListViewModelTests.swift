//
//  EBCoinsListViewModelTests.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 06/03/25.
//

import XCTest
import Combine
@testable import EquityCoin

final class EBCoinsListViewModelTests: XCTestCase {
    var viewModel: EBCoinsListViewModel!
    var mockService: MockCoinService!
    var mockCoordinator: MockCoordinator!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockService = MockCoinService()
        let window = UIWindow()
        let navigationController = UINavigationController()
        mockCoordinator = MockCoordinator(window: window, navigationController: navigationController, coinService: mockService)
        viewModel = EBCoinsListViewModel(coinService: mockService, coordinator: mockCoordinator)
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        mockCoordinator = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testFetchNextPage() async {
        // Given
        let mockCoins = [
            EBCoin(id: "1", name: "Bitcoin", symbol: "BTC", price: "50000", change: "5", sparkline: []),
            EBCoin(id: "2", name: "Ethereum", symbol: "ETH", price: "4000", change: "3", sparkline: [])
        ]
        mockService.mockCoins = mockCoins
        
        // When
        await viewModel.fetchNextPage()
        
        // Then
        XCTAssertEqual(viewModel.displayedCoins.count, mockCoins.count)
        XCTAssertEqual(viewModel.displayedCoins[0].name, "Bitcoin")
        XCTAssertEqual(viewModel.displayedCoins[1].name, "Ethereum")
    }
    
    func testRefreshCoins() async {
        // Given
        let mockCoins = [
            EBCoin(id: "1", name: "Bitcoin", symbol: "BTC", price: "50000", change: "5", sparkline: []),
            EBCoin(id: "2", name: "Ethereum", symbol: "ETH", price: "4000", change: "3", sparkline: [])
        ]
        mockService.mockCoins = mockCoins
        
        // When
        await viewModel.refreshCoins()
        
        // Then
        XCTAssertEqual(viewModel.displayedCoins.count, mockCoins.count)
        XCTAssertEqual(viewModel.displayedCoins[0].name, "Bitcoin")
        XCTAssertEqual(viewModel.displayedCoins[1].name, "Ethereum")
    }
    
    func testToggleFavorite() {
        // Given
        let coinId = "1"
        
        // When
        viewModel.toggleFavorite(coinId: coinId)
        
        // Then
        XCTAssertTrue(viewModel.favorites.contains(coinId))
        
        // When
        viewModel.toggleFavorite(coinId: coinId)
        
        // Then
        XCTAssertFalse(viewModel.favorites.contains(coinId))
    }
    
    func testFilterByHighestPrice() {
        // Given
        let mockCoins = [
            EBCoin(id: "1", name: "Bitcoin", symbol: "BTC", price: "50000", change: "5", sparkline: []),
            EBCoin(id: "2", name: "Ethereum", symbol: "ETH", price: "4000", change: "3", sparkline: [])
        ]
        mockService.mockCoins = mockCoins
        viewModel.coins = mockCoins
        
        // When
        viewModel.filterByHighestPrice(ascending: true)
        
        // Then
        XCTAssertEqual(viewModel.displayedCoins[0].name, "Ethereum")
        XCTAssertEqual(viewModel.displayedCoins[1].name, "Bitcoin")
        
        // When
        viewModel.filterByHighestPrice(ascending: false)
        
        // Then
        XCTAssertEqual(viewModel.displayedCoins[0].name, "Bitcoin")
        XCTAssertEqual(viewModel.displayedCoins[1].name, "Ethereum")
    }
    
    func testFilterByBestPerformance() {
        // Given
        let mockCoins = [
            EBCoin(id: "1", name: "Bitcoin", symbol: "BTC", price: "50000", change: "5", sparkline: []),
            EBCoin(id: "2", name: "Ethereum", symbol: "ETH", price: "4000", change: "3", sparkline: [])
        ]
        mockService.mockCoins = mockCoins
        viewModel.coins = mockCoins
        
        // When
        viewModel.filterByBestPerformance(ascending: true)
        
        // Then
        XCTAssertEqual(viewModel.displayedCoins[0].name, "Ethereum")
        XCTAssertEqual(viewModel.displayedCoins[1].name, "Bitcoin")
        
        // When
        viewModel.filterByBestPerformance(ascending: false)
        
        // Then
        XCTAssertEqual(viewModel.displayedCoins[0].name, "Bitcoin")
        XCTAssertEqual(viewModel.displayedCoins[1].name, "Ethereum")
    }
    
    func testFilterByName() {
        // Given
        let mockCoins = [
            EBCoin(id: "1", name: "Bitcoin", symbol: "BTC", price: "50000", change: "5", sparkline: []),
            EBCoin(id: "2", name: "Ethereum", symbol: "ETH", price: "4000", change: "3", sparkline: [])
        ]
        mockService.mockCoins = mockCoins
        viewModel.coins = mockCoins
        
        // When
        viewModel.filterByName(ascending: true)
        
        // Then
        XCTAssertEqual(viewModel.displayedCoins[0].name, "Bitcoin")
        XCTAssertEqual(viewModel.displayedCoins[1].name, "Ethereum")
        
        // When
        viewModel.filterByName(ascending: false)
        
        // Then
        XCTAssertEqual(viewModel.displayedCoins[0].name, "Ethereum")
        XCTAssertEqual(viewModel.displayedCoins[1].name, "Bitcoin")
    }
    
    func testDidSelectCoin() {
        // Given
        let coin = EBCoin(id: "1", name: "Bitcoin", symbol: "BTC", price: "50000", change: "5", sparkline: [])
        
        // When
        viewModel.didSelectCoin(coin)
        
        // Then
        XCTAssertTrue(mockCoordinator.didShowCoinDetail)
    }
    
    func testShowFavorites() {
        // Given
        let mockCoins = [
            EBCoin(id: "1", name: "Bitcoin", symbol: "BTC", price: "50000", change: "5", sparkline: []),
            EBCoin(id: "2", name: "Ethereum", symbol: "ETH", price: "4000", change: "3", sparkline: [])
        ]
        viewModel.coins = mockCoins
        viewModel.toggleFavorite(coinId: "1")
        
        // When
        viewModel.showFavorites()
        
        // Then
        XCTAssertTrue(mockCoordinator.didShowFavorites)
    }
}
