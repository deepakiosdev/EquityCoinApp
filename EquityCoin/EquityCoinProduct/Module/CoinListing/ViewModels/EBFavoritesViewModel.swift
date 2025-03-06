//
//  EBFavoritesViewModel.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 26/02/25.
//

import Foundation
import Combine

final class EBFavoritesViewModel: EBFavoritesViewModelProtocol {
    private let coordinator: EBAppCoordinator
    @Published var favoriteCoins: [EBCoin] = []
    private let toggleFavorite: (String) -> Void
    var favoriteCoinsPublisher: Published<[EBCoin]>.Publisher { $favoriteCoins }
    
    init(favoriteCoins: [EBCoin],
         toggleFavorite: @escaping (String) -> Void,
         coordinator: EBAppCoordinator) {
        self.favoriteCoins = favoriteCoins
        self.toggleFavorite = toggleFavorite
        self.coordinator = coordinator
    }
    
    func toggleFavoriteAndGetRemovedIndex(coinId: String) -> Int? {
            // Find and remove the coin from favoriteCoins, returning its index
            if let index = favoriteCoins.firstIndex(where: { $0.id == coinId }) {
                favoriteCoins.remove(at: index)
                toggleFavorite(coinId)
                return index
            }
            return nil
        }
    
    func toggleFavorite(coinId: String) {
        // Remove the coin from favoriteCoins locally first
        favoriteCoins.removeAll { $0.id == coinId }
        toggleFavorite(coinId)
    }
    
    func didSelectCoin(_ coin: EBCoin) {
        coordinator
            .showCoinDetail(coin: coin, isFavorite: true) {[weak self] coinId in
                self?.toggleFavorite(coinId: coinId)
            }
    }
}
