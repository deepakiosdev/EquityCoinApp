//
//  MockCoordinator.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 06/03/25.
//

import UIKit

class MockCoordinator: EBAppCoordinator {
    var didShowCoinDetail = false
    var didShowFavorites = false
    
    override init(window: UIWindow, navigationController: UINavigationController, coinService: EBCoinServiceProtocol) {
        super.init(window: window, navigationController: navigationController, coinService: coinService)
    }
    
    override func showCoinDetail(
        coin: EBCoin,
        isFavorite: Bool,
        toggleFavorite onFavoriteToggle: @escaping (String) -> Void
    ) {
        didShowCoinDetail = true
    }
    
    override func showFavorites(
        favoriteCoins: [EBCoin],
        toggleFavorite onFavoriteToggle: @escaping (String) -> Void
    ) {
        didShowFavorites = true
    }
}
