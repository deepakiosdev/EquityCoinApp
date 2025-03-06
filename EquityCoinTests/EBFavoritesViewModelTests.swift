import XCTest
import Combine
@testable import EquityCoin

final class EBFavoritesViewModelTests: XCTestCase {
    var viewModel: EBFavoritesViewModel!
    var mockCoordinator: MockCoordinator!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockCoordinator = MockCoordinator(window: UIWindow(), navigationController: UINavigationController(), coinService: MockCoinService())
        viewModel = EBFavoritesViewModel(favoriteCoins: [], toggleFavorite: { _ in }, coordinator: mockCoordinator)
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockCoordinator = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testToggleFavoriteAndGetRemovedIndex() {
        // Given
        let coin = EBCoin(id: "1", name: "Bitcoin", symbol: "BTC", price: "50000", change: "5", sparkline: [])
        viewModel.favoriteCoins = [coin]
        
        // When
        let removedIndex = viewModel.toggleFavoriteAndGetRemovedIndex(coinId: coin.id)
        
        // Then
        XCTAssertEqual(removedIndex, 0)
        XCTAssertTrue(viewModel.favoriteCoins.isEmpty)
    }
    
    func testToggleFavorite() {
        // Given
        let coin = EBCoin(id: "1", name: "Bitcoin", symbol: "BTC", price: "50000", change: "5", sparkline: [])
        viewModel.favoriteCoins = [coin]
        
        // When
        viewModel.toggleFavorite(coinId: coin.id)
        
        // Then
        XCTAssertTrue(viewModel.favoriteCoins.isEmpty)
    }
    
    func testDidSelectCoin() {
        // Given
        let coin = EBCoin(id: "1", name: "Bitcoin", symbol: "BTC", price: "50000", change: "5", sparkline: [])
        
        // When
        viewModel.didSelectCoin(coin)
        
        // Then
        XCTAssertTrue(mockCoordinator.didShowCoinDetail)
    }
    
    func testFavoriteCoinsPublisher() {
        // Given
        let expectation = XCTestExpectation(description: "Favorite coins publisher should emit values")
        var receivedValues: [[EBCoin]] = []
        
        viewModel.favoriteCoinsPublisher
            .sink { value in
                print("Received value: \(value)")
                receivedValues.append(value)
                if receivedValues.count == 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        let coin = EBCoin(id: "1", name: "Bitcoin", symbol: "BTC", price: "50000", change: "5", sparkline: [])
        viewModel.favoriteCoins = [coin]
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        
        // Ensure that receivedValues has two elements before accessing its elements
        XCTAssertEqual(receivedValues.count, 2)
        XCTAssertEqual(receivedValues[1].count, 1)
        XCTAssertEqual(receivedValues[1][0].name, "Bitcoin")
    }
}
