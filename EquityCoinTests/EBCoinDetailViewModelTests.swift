//
//  EBCoinDetailViewModelTests.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 06/03/25.
//


import XCTest
import Combine
@testable import EquityCoin

final class EBCoinDetailViewModelTests: XCTestCase {
    var viewModel: EBCoinDetailViewModel!
    var mockService: MockCoinService!
    var mockCoordinator: MockCoordinator!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockService = MockCoinService()
        let window = UIWindow()
        let navigationController = UINavigationController()
        mockCoordinator = MockCoordinator(window: window, navigationController: navigationController, coinService: mockService)
        let coin = EBCoinModel(id: "1", name: "Bitcoin", symbol: "BTC", price: "50000", change: "5", rank: 1, volume24h: "1000000", marketCap: "1000000000", listedAt: 1234567890, btcPrice: "1.0",
                               sparkline: ["50000", "50500"])
        viewModel = EBCoinDetailViewModel(coin: coin, coinService: mockService, coordinator: mockCoordinator, isFavorite: false, toggleFavoriteCallBack: { _ in })
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        mockCoordinator = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testFetchHistorySuccess() async {
        // Given
        let mockHistory = [
            EBCoinHistory(price: "50000", timestamp: 1234567890),
            EBCoinHistory(price: "50500", timestamp: 1234567891)
        ]
        mockService.mockHistory = mockHistory
        
        // When
        await viewModel.fetchHistory(for: .day)
        
        // Then
        XCTAssertEqual(viewModel.history.count, mockHistory.count)
        XCTAssertEqual(viewModel.chartData.count, mockHistory.count)
        XCTAssertEqual(viewModel.chartData[0], 50000)
        XCTAssertEqual(viewModel.chartData[1], 50500)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testFetchHistoryFailure() async {
        // Given
        mockService.mockHistory = []
        
        // When
        await viewModel.fetchHistory(for: .day)
        
        // Then
        XCTAssertTrue(viewModel.history.isEmpty)
        XCTAssertEqual(viewModel.chartData.count, 2)
        XCTAssertEqual(viewModel.chartData[0], 50000)
        XCTAssertEqual(viewModel.chartData[1], 50500)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testToggleFavorite() {
        // Given
        let coinId = "1"
        
        // When
        viewModel.toggleFavorite()
        
        // Then
        XCTAssertTrue(viewModel.favorites.contains(coinId))
        
        // When
        viewModel.toggleFavorite()
        
        // Then
        XCTAssertFalse(viewModel.favorites.contains(coinId))
    }
    
    func testChartDataPublisher() {
        // Given
        let expectation = XCTestExpectation(description: "Chart data publisher should emit values")
        var receivedValues: [[Double]] = []
        
        viewModel.chartDataPublisher
            .sink { value in
                print("Received value: \(value)")
                receivedValues.append(value)
                if receivedValues.count == 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        let mockHistory = [
            EBCoinHistory(price: "50000", timestamp: 1234567890),
            EBCoinHistory(price: "50500", timestamp: 1234567891)
        ]
        mockService.mockHistory = mockHistory
        Task { await viewModel.fetchHistory(for: .day) }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertFalse(receivedValues.isEmpty, "receivedValues should not be empty")
        XCTAssertEqual(receivedValues.count, 3)
        XCTAssertEqual(receivedValues[1].count, 2)
        XCTAssertEqual(receivedValues[1][0], 50000)
        XCTAssertEqual(receivedValues[1][1], 50500)
    }
}
