//
//  EBCoinsListViewModelProtocol.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 26/02/25.
//

import Foundation
import Combine

/// Defines the interface for the coins list view model, ensuring consistency across implementations.
protocol EBCoinsListViewModelProtocol {
    var displayedCoins: [EBCoin] { get }
    var currentPage: Int { get }
    var favorites: Set<String> { get }
    var errorMessage: String? { get }
    var displayedCoinsPublisher: Published<[EBCoin]>.Publisher { get }
    var errorMessagePublisher: Published<String?>.Publisher { get }
    func fetchNextPage() async
    func refreshCoins() async
    func filterByHighestPrice(ascending: Bool)
    func filterByBestPerformance(ascending: Bool)
    func filterByName(ascending: Bool)
    func toggleFavorite(coinId: String)
    func didSelectCoin(_ coin: EBCoin)
    func showFavorites()
    func updateDisplayedCoins()
}
