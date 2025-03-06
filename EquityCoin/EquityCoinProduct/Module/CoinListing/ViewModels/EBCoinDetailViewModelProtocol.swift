//
//  EBCoinDetailViewModelProtocol.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 04/03/25.
//

import Foundation

protocol EBCoinDetailViewModelProtocol {
    var chartData: [Double] { get }
    var coin: EBCoinModel { get }
    var rank: Int? { get }
    var isFavorite: Bool { get }
    var volume24h: String? { get }
    var marketCap: String? { get }
    var listingDate: Date? { get }
    var btcPrice: String? { get }
    var chartDataPublisher: Published<[Double]>.Publisher { get }
    var errorMessagePublisher: Published<String?>.Publisher { get }
    var favorites: Set<String> { get }
    func fetchHistory(for period: ChartPeriod) async
    func toggleFavorite()
}
