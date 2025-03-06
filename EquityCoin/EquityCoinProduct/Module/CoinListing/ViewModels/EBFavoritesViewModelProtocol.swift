//
//  EBFavoritesViewModelProtocol.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 28/02/25.
//

import Combine

protocol EBFavoritesViewModelProtocol {
    var favoriteCoins: [EBCoin] { get }
    var favoriteCoinsPublisher: Published<[EBCoin]>.Publisher { get }
    func toggleFavoriteAndGetRemovedIndex(coinId: String) -> Int?
    func toggleFavorite(coinId: String)
    func didSelectCoin(_ coin: EBCoin)
}
