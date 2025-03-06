//
//  EBCoinsListViewModel.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 26/02/25.
//

import Foundation
import Combine

/// Manages the state and data for the list of top 100 coins, including pagination, filtering, and favorites.
final class EBCoinsListViewModel: EBCoinsListViewModelProtocol {
    private let coinService: EBCoinServiceProtocol
    private let coordinator: EBAppCoordinator
    var coins: [EBCoin] = []
    private(set) var favorites: Set<String> = []
    private let itemsPerPage = 20
    
    @Published var displayedCoins: [EBCoin] = []
    @Published var currentPage = 1
    @Published var errorMessage: String?
    
    // Publishers for protocol conformance
    var displayedCoinsPublisher: Published<[EBCoin]>.Publisher { $displayedCoins }
    var errorMessagePublisher: Published<String?>.Publisher { $errorMessage }
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(coinService: EBCoinServiceProtocol, coordinator: EBAppCoordinator) {
        self.coinService = coinService
        self.coordinator = coordinator
    }
    
    private func reloadFavorites() {
        updateDisplayedCoins()
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    /// Fetches the next page of coins, handling pagination and errors, removing duplicates.
    func fetchNextPage() async {
        debugPrint("Fetching page \(currentPage) of coins")
        do {
            let newCoins = try await coinService.fetchCoins(page: currentPage, limit: itemsPerPage)
            // Remove duplicates based on UUID (id)
            let uniqueCoins = Array(NSOrderedSet(array: newCoins.map { $0.id }).array as! [String]).compactMap { id in newCoins.first { $0.id == id } }
            coins.append(contentsOf: uniqueCoins)
            currentPage += 1
            updateDisplayedCoins()
            errorMessage = nil
            debugPrint("Fetched coins: \(uniqueCoins.count), total coins: \(coins.count)")
        } catch let error as EBNetworkError {
            errorMessage = error.localizedDescription
            debugPrint("API Error fetching coins: \(error.localizedDescription)")
        } catch {
            errorMessage = "Unexpected error: \(error.localizedDescription)"
            debugPrint("Unexpected error fetching coins: \(error.localizedDescription)")
        }
    }
    
    /// Refreshes the first page of coins for pull-to-refresh, handling errors.
    func refreshCoins() async {
        debugPrint("Refreshing coin list")
        currentPage = 1
        coins.removeAll()
        await fetchNextPage()
    }
    
    /// Filters coins by highest price in ascending or descending order.
    func filterByHighestPrice(ascending: Bool) {
        displayedCoins = coins.sorted { ascending ? $0.priceDouble < $1.priceDouble : $0.priceDouble > $1.priceDouble }
        debugPrint("Filtered by price, ascending: \(ascending)")
    }
    
    /// Filters coins by best 24-hour performance in ascending or descending order.
    func filterByBestPerformance(ascending: Bool) {
        displayedCoins = coins.sorted { ascending ? $0.changeDouble < $1.changeDouble : $0.changeDouble > $1.changeDouble }
        debugPrint("Filtered by 24H% change, ascending: \(ascending)")
    }
    
    /// Filters coins by name in ascending or descending order.
    func filterByName(ascending: Bool) {
        displayedCoins = coins.sorted { ascending ? ($0.name) < ($1.name) : ($0.name) > ($1.name) }
        debugPrint("Filtered by name, ascending: \(ascending)")
    }
    
    /// Toggles a coin's favorite status and updates the UI.
    func toggleFavorite(coinId: String) {
        if !coinId.isEmpty {
            if favorites.contains(coinId) {
                favorites.remove(coinId)
            } else {
                favorites.insert(coinId)
            }
            debugPrint("Toggled favorite for coin \(coinId), favorites count: \(favorites.count)")
            updateDisplayedCoins()
        }
    }
    
    func isFavorite(_ coinId: String) -> Bool {
        return favorites.contains(coinId)
    }
    /// Navigates to the coin detail view.
    func didSelectCoin(_ coin: EBCoin) {
        coordinator
            .showCoinDetail(coin: coin, isFavorite: isFavorite(coin.id)) {[weak self] coinId in
                self?.toggleFavorite(coinId: coinId)
            }
        debugPrint("Navigated to detail for coin: \(coin.name)")
    }
    
    /// Navigates to the favorites screen.
    func showFavorites() {
        let favoriteCoins = displayedCoins.filter { favorites.contains($0.id) }
        coordinator.showFavorites(favoriteCoins: favoriteCoins) { [weak self] coinId in
            self?.toggleFavorite(coinId: coinId)
        }
        debugPrint("Navigated to favorites screen")
    }
    
    /// Updates displayed coins based on current page and applied filters.
    func updateDisplayedCoins() {
        displayedCoins = Array(coins.prefix(currentPage * itemsPerPage))
        debugPrint("Updated displayed coins, count: \(displayedCoins.count)")
    }
}
