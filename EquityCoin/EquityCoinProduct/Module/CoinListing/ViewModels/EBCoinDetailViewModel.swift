//
//  EBCoinDetailViewModel.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 26/02/25.
//

import Foundation
import Combine
import Charts

/// Manages the state and data for a coin's detail view, including history and chart data.
final class EBCoinDetailViewModel: EBCoinDetailViewModelProtocol {
    let isFavorite: Bool
    private let coinService: EBCoinServiceProtocol
    private let coordinator: EBAppCoordinator
    private let toggleFavoriteCallBack: (String) -> Void
    let coin: EBCoinModel
    @Published var history: [EBCoinHistory] = []
    @Published var selectedTimePeriod: ChartPeriod = .day
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    // Stored property for chart data as [Double] to match protocol
    @Published var chartData: [Double] = []
    @Published var favorites: Set<String> = []
    
    // Computed properties for chart and coin details, matching protocol
    var high24h: Double { history.map { $0.priceDouble }.max() ?? coin.sparkline.compactMap { Double($0) ?? 0.0 }.max() ?? 0 }
    var low24h: Double { history.map { $0.priceDouble }.min() ?? coin.sparkline.compactMap { Double($0) ?? 0.0 }.min() ?? 0 }
    var rank: Int? { coin.rank }
    var volume24h: String? { coin.volume24h ?? "N/A" }
    var marketCap: String? { coin.marketCap ?? "N/A" }
    var launchDate: Date? { nil }
    var listingDate: Date? { coin.listedAt.map { Date(timeIntervalSince1970: TimeInterval($0)) } }
    var btcPrice: String? { coin.btcPrice ?? "N/A" }
    
    var chartDataPublisher: Published<[Double]>.Publisher { $chartData } // Updated to match protocol
    
    var errorMessagePublisher: Published<String?>.Publisher { $errorMessage }
    
    // MARK: - Initialization
    init(coin: EBCoinModel,
         coinService: EBCoinServiceProtocol,
         coordinator: EBAppCoordinator,
         isFavorite: Bool,
         toggleFavoriteCallBack: @escaping (String) -> Void) {
        self.coin = coin
        self.coinService = coinService
        self.coordinator = coordinator
        self.isFavorite = isFavorite
        self.toggleFavoriteCallBack = toggleFavoriteCallBack
        self.chartData = self.chartData
        Task { await fetchHistory(for: selectedTimePeriod) }
    }
    
    // MARK: - Methods
    func fetchHistory(for period: ChartPeriod) async {
        isLoading = true
        debugPrint("Fetching history for coin \(coin.name) with time period: \(period)")
        let timePeriodString: String = convertPeriodToString(period)
        guard EBAPIConstants.validTimePeriods.contains(timePeriodString) else {
            errorMessage = "Invalid time period selected"
            isLoading = false
            return
        }
        selectedTimePeriod = period
        do {
            history = try await coinService.fetchCoinHistory(coinId: coin.id, timePeriod: timePeriodString)
            debugPrint("History response: \(history)")
            // Update chartData based on history or sparkline
            self.chartData = history.map { $0.priceDouble }
            if history.isEmpty {
                self.chartData = coin.sparkline.compactMap { Double($0) ?? 0.0 }
            }
            errorMessage = nil
        } catch let error as EBNetworkError {
            errorMessage = error.localizedDescription
            debugPrint("API Error fetching history: \(error.localizedDescription)")
        } catch {
            errorMessage = "Unexpected error: \(error.localizedDescription)"
            debugPrint("Unexpected error fetching history: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    func toggleFavorite() {
        toggleFavorite(coinId: coin.id)
    }
    
    private func toggleFavorite(coinId: String) {
        if !coinId.isEmpty {
            if favorites.contains(coinId) {
                favorites.remove(coinId)
            } else {
                favorites.insert(coinId)
            }
            toggleFavoriteCallBack(coinId)
            debugPrint("Toggled favorite status for coin \(coinId), favorites count: \(favorites.count)")
        }
    }
    
    // Helper to convert ChartPeriod to String for API
    private func convertPeriodToString(_ period: ChartPeriod) -> String {
        switch period {
        case .hour: return "1h"
        case .threeHours: return "3h"
        case .twelveHours: return "12h"
        case .day: return "24h"
        case .week: return "7d"
        case .month: return "30d"
        case .threeMonths: return "3m"
        case .year: return "1y"
        case .threeYears: return "3y"
        case .fiveYears: return "5y"
        }
    }
}
