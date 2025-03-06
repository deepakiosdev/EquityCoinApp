import UIKit
import SwiftUI
import Combine

/// Manages the UI for displaying the list of top 100 cryptocurrencies with pagination and filtering.
final class EBCoinsListViewController: UIViewController {
    private let viewModel: EBCoinsListViewModelProtocol
    private var tableView: UITableView!
    private var filterView: UIHostingController<EBFilterButtonView>!
    private var errorView: UIView?
    private var cancellables: Set<AnyCancellable> = []
    private var refreshControl: UIRefreshControl!
    private var filterState: FilterState!
    
    init(viewModel: EBCoinsListViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        Task { await viewModel.fetchNextPage() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

// MARK: - UI Setup
private extension EBCoinsListViewController {
    func setupUI() {
        title = EBDisplayStrings.top100CoinsTitle
        view.backgroundColor = .systemBackground
        
        filterState = FilterState()
        filterView = UIHostingController(rootView: EBFilterButtonView(
            onPriceFilter: { [weak self] ascending in
                self?.applyFilter(.price, ascending: ascending)
            },
            onPerformanceFilter: { [weak self] ascending in
                self?.applyFilter(.performance, ascending: ascending)
            },
            onNameFilter: { [weak self] ascending in
                self?.applyFilter(.name, ascending: ascending)
            },
            filterState: filterState
        ))
        addChild(filterView)
        view.addSubview(filterView.view)
        filterView.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            filterView.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            filterView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterView.view.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.prefetchDataSource = self
        tableView.register(EBHostingTableViewCell<EBCoinCellView>.self, forCellReuseIdentifier: "EBCoinCell")
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        tableView.refreshControl = refreshControl
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: filterView.view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: EBDisplayStrings.favoritesTitle,
            style: .plain,
            target: self,
            action: #selector(showFavoritesTapped)
        )
        
        setupErrorView()
        
        // Observe filter state changes to ensure UI updates
        filterState.$selectedFilter
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateFilterUI()
            }
            .store(in: &cancellables)
    }
    
    func applyFilter(_ type: FilterType, ascending: Bool) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            switch type {
            case .price: self.viewModel.filterByHighestPrice(ascending: ascending)
            case .performance: self.viewModel.filterByBestPerformance(ascending: ascending)
            case .name: self.viewModel.filterByName(ascending: ascending)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func bindViewModel() {
        viewModel.displayedCoinsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coins in
                guard let self = self else { return }
                self.errorView?.isHidden = !coins.isEmpty || self.viewModel.errorMessage == nil
                UIView.transition(with: self.tableView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    self.tableView.reloadData()
                })
                self.refreshControl.endRefreshing()
            }
            .store(in: &cancellables)
        
        viewModel.errorMessagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                guard let self = self, let message = message, self.viewModel.currentPage == 1 else {
                    self?.errorView?.isHidden = true
                    return
                }
                self.errorView?.isHidden = false
                if let errorView = self.errorView {
                    (errorView.subviews.first(where: { $0 is UILabel }) as? UILabel)?.text = message
                }
            }
            .store(in: &cancellables)
    }
    
    func setupErrorView() {
        let errorView = UIView()
        errorView.backgroundColor = .systemBackground
        errorView.isHidden = true
        
        let errorLabel = UILabel()
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        
        let refreshButton = UIButton(type: .system)
        refreshButton.setTitle(EBDisplayStrings.refreshButton, for: .normal)
        refreshButton.addTarget(self, action: #selector(refreshTapped), for: .touchUpInside)
        
        errorView.addSubview(errorLabel)
        errorView.addSubview(refreshButton)
        view.addSubview(errorView)
        
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        errorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            errorView.topAnchor.constraint(equalTo: filterView.view.bottomAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            errorLabel.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: errorView.centerYAnchor, constant: -20),
            errorLabel.leadingAnchor.constraint(greaterThanOrEqualTo: errorView.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(lessThanOrEqualTo: errorView.trailingAnchor, constant: -16),
            refreshButton.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            refreshButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16)
        ])
        
        self.errorView = errorView
    }
    
    func updateFilterUI() {
        filterView.view.setNeedsDisplay()
        filterView.view.setNeedsLayout()
    }
    
    @objc func updateDisplayedCoins() {
        viewModel.updateDisplayedCoins()
        tableView.reloadData()
    }
}

// MARK: - Table View Data Source, Delegate, and Prefetching
extension EBCoinsListViewController: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.displayedCoins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EBCoinCell", for: indexPath) as? EBHostingTableViewCell<EBCoinCellView> else {
            return UITableViewCell()
        }
        let coin = viewModel.displayedCoins[indexPath.row]
        let isFavorite = viewModel.favorites.contains(coin.id)
        cell.host(EBCoinCellView(coin: coin, isFavorite: isFavorite))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let coin = viewModel.displayedCoins[indexPath.row]
        viewModel.didSelectCoin(coin)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let lastIndex = viewModel.displayedCoins.count - 1
        if indexPaths.contains(where: { $0.row >= lastIndex - 5 }) {
            Task { await viewModel.fetchNextPage() }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let coin = viewModel.displayedCoins[indexPath.row]
        let isFavorite = viewModel.favorites.contains(coin.id)
        let action = UIContextualAction(style: .normal, title: isFavorite ? EBDisplayStrings.unfavoriteTitle : EBDisplayStrings.favoriteTitle) { [weak self] _, _, completion in
            self?.viewModel.toggleFavorite(coinId: coin.id)
            completion(true)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        action.backgroundColor = isFavorite ? .systemRed : .systemGreen
        return UISwipeActionsConfiguration(actions: [action])
    }
}

// MARK: - Actions and Helpers
private extension EBCoinsListViewController {
    @objc func showFavoritesTapped() {
        viewModel.showFavorites()
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: EBDisplayStrings.errorTitle, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: EBDisplayStrings.okButton, style: .default))
        present(alert, animated: true)
    }
    
    @objc private func refreshTapped() {
        errorView?.isHidden = true
        Task { await viewModel.refreshCoins() }
    }
    
    @objc private func refreshPulled() {
        filterState.resetFilters()
        Task { await viewModel.refreshCoins() }
        tableView.refreshControl?.endRefreshing()
        updateFilterUI()
    }
}
