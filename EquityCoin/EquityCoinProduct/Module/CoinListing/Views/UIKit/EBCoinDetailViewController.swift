//
//  EBCoinDetailViewController.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on  04/03/25.
//

import UIKit
import SwiftUI
import Combine
import Foundation

/// Manages the UI for displaying detailed information about a specific cryptocurrency.
final class EBCoinDetailViewController: UIViewController {
    private let viewModel: EBCoinDetailViewModelProtocol
    private var chartHostingController: UIHostingController<EBChartView>!
    private var filterView: UIHostingController<EBChartFilterButtonView>!
    private var statsView: UIStackView!
    private var cancellables: Set<AnyCancellable> = []
    
    init(viewModel: EBCoinDetailViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        view.backgroundColor = .systemBackground
    }
}

// MARK: - UI Setup
private extension EBCoinDetailViewController {
    func setupUI() {
        title = viewModel.coin.name
        view.backgroundColor = .systemBackground
        let ebcoin = EBCoin(from: viewModel.coin)
        let chartView = EBChartView(
            data: viewModel.chartData,
            coin: ebcoin,
            isFavorite: self.viewModel.isFavorite,
            toggleFavorite: { coinId in
                print("Toggled favorite for coin: \(coinId)")
                self.viewModel.toggleFavorite()
            }
        )
        // Chart View (SwiftUI chart hosted in UIKit, using CoinListing's EBChartView)
        chartHostingController = UIHostingController(rootView: chartView)
        addChild(chartHostingController)
        view.addSubview(chartHostingController.view)
        chartHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chartHostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            chartHostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chartHostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chartHostingController.view.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        // Filter View (using UIKit hosting SwiftUI filter buttons)
        filterView = UIHostingController(rootView: EBChartFilterButtonView(
            onFilter: { [weak self] period in
                Task { await self?.viewModel.fetchHistory(for: period) }
            }
        ))
        addChild(filterView)
        view.addSubview(filterView.view)
        filterView.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            filterView.view.topAnchor.constraint(equalTo: chartHostingController.view.bottomAnchor),
            filterView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterView.view.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Stats View (UIKit stack view for coin stats)
        statsView = UIStackView()
        statsView.axis = .vertical
        statsView.spacing = 8
        statsView.distribution = .fillEqually
        statsView.translatesAutoresizingMaskIntoConstraints = false
        statsView.backgroundColor = .systemBackground
 
        let stats = [
                    StatDisplayString.format(StatDisplayString.rank, value: viewModel.rank),
                    StatDisplayString.format(StatDisplayString.volume24h, value: viewModel.volume24h),
                    StatDisplayString.format(StatDisplayString.marketCap, value: viewModel.marketCap),
                    StatDisplayString.format(StatDisplayString.listingDate, value: viewModel.listingDate?.formatted(.dateTime.day().month().year())),
                    StatDisplayString.format(StatDisplayString.btcPrice, value: viewModel.btcPrice)
                ]
        
        stats.forEach { stat in
            let label = UILabel()
            label.text = stat
            label.textColor = .label
            label.font = .systemFont(ofSize: 14)
            statsView.addArrangedSubview(label)
        }
        
        view.addSubview(statsView)
        NSLayoutConstraint.activate([
            statsView.topAnchor.constraint(equalTo: filterView.view.bottomAnchor, constant: 16),
            statsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
    }
    
    func bindViewModel() {
        viewModel.chartDataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                guard let self = self else { return }
                
                let ebcoin = EBCoin(from: viewModel.coin)
                let chartView = EBChartView(
                    data: data,
                    coin: ebcoin,
                    isFavorite: self.viewModel.isFavorite,
                    toggleFavorite: { coinId in
                        print("Toggled favorite for coin: \(coinId)")
                        self.viewModel.toggleFavorite()
                    }
                )
                
                self.chartHostingController.rootView = chartView
                self.updateStats()
            }
            .store(in: &cancellables)
        
        viewModel.errorMessagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                if let message = message { self?.showAlert(message: message) }
            }
            .store(in: &cancellables)
    }
    
    func updateStats() {
        let stats = [
            "Rank: \(viewModel.rank ?? 0)",
            "24h Volume: \(viewModel.volume24h ?? "N/A")",
            "Market Cap: \(viewModel.marketCap ?? "N/A")",
            "Listing Date: \(viewModel.listingDate?.formatted(.dateTime.day().month().year()) ?? "N/A")",
            "BTC Price: \(viewModel.btcPrice ?? "N/A")"
        ]
        stats.enumerated().forEach { index, stat in
            if let label = statsView.arrangedSubviews[index] as? UILabel {
                label.text = stat
                label.textColor = .label // Ensure dynamic text color
            }
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
