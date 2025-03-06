//
//  EBFavoritesViewController.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 26/02/25.
//

import UIKit
import SwiftUI
import Combine

final class EBFavoritesViewController: UIViewController {
    private let viewModel: EBFavoritesViewModel
    private var tableView: UITableView!
    private var cancellables: Set<AnyCancellable> = []
    
    init(viewModel: EBFavoritesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
}

private extension EBFavoritesViewController {
    func setupUI() {
        title = EBDisplayStrings.favoritesTitle
        view.backgroundColor = .systemBackground
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(EBHostingTableViewCell<EBCoinCellView>.self, forCellReuseIdentifier: "EBCoinCell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func bindViewModel() {
        viewModel.favoriteCoinsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                UIView.transition(with: self.tableView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    self.tableView.reloadData()
                })
            }
            .store(in: &cancellables)
    }
}

extension EBFavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.favoriteCoins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EBCoinCell", for: indexPath) as? EBHostingTableViewCell<EBCoinCellView> else {
            return UITableViewCell()
        }
        let coin = viewModel.favoriteCoins[indexPath.row]
        cell.host(EBCoinCellView(coin: coin, isFavorite: true))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let coin = viewModel.favoriteCoins[indexPath.row]
        viewModel.didSelectCoin(coin)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let coin = viewModel.favoriteCoins[indexPath.row]
        let unfavoriteAction = UIContextualAction(
            style: .destructive,
            title: EBDisplayStrings.unfavoriteTitle) {
            [weak self] _,
            _,
            completion in
            guard let self = self else { return }
            let coinId = coin.id
            if let removedIndex = self.viewModel.toggleFavoriteAndGetRemovedIndex(coinId: coinId) {
                tableView.deleteRows(at: [IndexPath(row: removedIndex, section: indexPath.section)], with: .automatic)
            }
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [unfavoriteAction])
    }
}
