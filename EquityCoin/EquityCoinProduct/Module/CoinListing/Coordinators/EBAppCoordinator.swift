//
//  EBAppCoordinator.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 26/02/25.
//

import UIKit

/// Manages the navigation flow and coordination between app screens.
class EBAppCoordinator {
    private let window: UIWindow
    private let navigationController: UINavigationController
    private let coinService: EBCoinServiceProtocol
    
    init(window: UIWindow, navigationController: UINavigationController, coinService: EBCoinServiceProtocol) {
        self.window = window
        self.navigationController = navigationController
        self.coinService = coinService
    }
    
    func start() {
        let viewModel = EBCoinsListViewModel(coinService: coinService, coordinator: self)
        let viewController = EBCoinsListViewController(viewModel: viewModel)
        navigationController.viewControllers = [viewController]
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    func showCoinDetail(coin: EBCoin,
                        isFavorite: Bool,
                        toggleFavorite: @escaping (String) -> Void) {

        let coinModel = EBCoinModel(from: coin)
        let viewModel = EBCoinDetailViewModel(
            coin: coinModel,
            coinService: coinService,
            coordinator: self,
            isFavorite: isFavorite,
            toggleFavoriteCallBack: toggleFavorite)
        let viewController = EBCoinDetailViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showFavorites(favoriteCoins: [EBCoin], toggleFavorite: @escaping (String) -> Void) {
        // Create favorites view model with filtered favorite coins and toggle callback
        let favoritesViewModel = EBFavoritesViewModel(favoriteCoins: favoriteCoins, toggleFavorite: toggleFavorite, coordinator: self)
        let favoritesVC = EBFavoritesViewController(viewModel: favoritesViewModel)
        navigationController.pushViewController(favoritesVC, animated: true)
    }
}
