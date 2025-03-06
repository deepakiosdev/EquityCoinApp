# EquityCoin

An iOS application showcasing the top 100 cryptocurrencies with details, favorites and performance chart

## Requirements
- iOS 16.0+
- Xcode 15.0+
- CoinRanking API key (add to `EBCoinRankingService.swift`)

## Setup Instructions
1. Clone the repository: `git clone <repo-url>`
2. Open `EquityCoin.xcodeproj` in Xcode.
3. Add your CoinRanking API key in `EBCoinRankingService.swift`. If current key expired.
4. Build and run on a simulator or device.

## Architecture
- **MVVM + IO**: ViewModels (e.g., `EBCoinsListViewModel`, `EBCoinDetailViewModel`, `EBFavoritesViewModel`) handle inputs and outputs using Combine publishers.
- **Coordinator**: `EBAppCoordinator` manages navigation with dependency injection for `UIWindow`, `UINavigationController`, and `EBCoinServiceProtocol`.
- **UIKit + SwiftUI**: UIKit for main view controllers (`EBCoinsListViewController`, `EBCoinDetailViewController`, `EBFavoritesViewController`), SwiftUI for reusable components (e.g., `EBChartView`, `EBCoinCellView`).
- **Dependency Injection**: Services like `EBCoinServiceProtocol` and network layers injected into view models and coordinators for testability.
- **SOLID & DRY**: Reusable network layer (`EBNetworkService`), string templates (`EBDisplayStrings`, `StatDisplayString`), and UI components.

## Features
- Paginated list of top 100 coins (20 per page) with pull-to-refresh.
- Filters for highest price, best 24-hour performance, and alphabetical name sorting.
- Swipe actions to favorite/unfavorite coins in both list and favorites views.
- Coin details with a reusable `EBChartView` supporting multiple time periods (1h, 3h, 12h, 24h, 7d, 30d, 3m, 1y, 3y, 5y).
- Favorites screen reusing `EBCoinCellView` with swipe-to-unfavorite functionality.
- Simple animations (table reload with cross-dissolve, chart updates, cell appearance).
- Light and dark mode support

## Assumptions & Decisions
- Prefixed all classes with "EB" for Equity Bank branding consistency (e.g., `EBAppCoordinator`, `EBCoinDetailViewModel`).
- Reusable network layer with `EBRequestable` and `EBResponseHandler` for API calls.
- Code-based UIKit project for navigation flexibility via `EBAppCoordinator`.
- `EBCoinModel` and `EBCoin` types interoperate via conversion initializers (e.g., `EBCoinModel(from: EBCoin)`).
- Separated stat display strings into `StatDisplayString.swift` for modularity and reusability.
- App will not support offline mode
- By default no filter will apply on listing screen. Default list will be display coin in same order that we recevied from API response.
- Up arrow represnts ascending order (from lowest to highest) 

## Challenges & Solutions
- **SwiftUI/UIKit Integration**: Used `UIHostingController` to embed SwiftUI views (e.g., `EBChartView`, `EBFilterButtonView`) in UIKit controllers seamlessly.
- **Favorite State Management**: Updated `EBChartView` to use `@State` for local state syncing with parent via callbacks, resolving toggle issues.
- **Private Property Access in Tests**: Adjusted tests to use public properties (e.g., `displayedCoins`) instead of private `coins` in `EBCoinsListViewModel`.
- **Chart Creation**: Implemented a mountain-style chart in `EBChartView` using SwiftUI Charts with `AreaMark` and `LineMark`, ensuring dynamic scaling with min/max Y-values from price data.
- **SVG Image Downloading**: Integrated `SDWebImage` and SVGKit to download and render SVG icons. But thsese 3rd party sdk causing scrolling, performance issues and crashes. Build native solution that is working fine.

## Edge Cases
- Empty coin lists or favorites handled with "No data available" messages.
- Network failures display error alerts with retry options (`EBCoinsListViewController`).
- Pagination caps at 100 coins as per API design.
- Invalid time periods in `EBCoinDetailViewModel` trigger error messages gracefully.

## Notes
- Unit tests expanded to include `EBFavoritesViewModelTests.swift`, `EBCoinDetailViewModelTests.swift`, and `EBCoinsListViewModel


## TODO: 
- Make chart Interactive 
