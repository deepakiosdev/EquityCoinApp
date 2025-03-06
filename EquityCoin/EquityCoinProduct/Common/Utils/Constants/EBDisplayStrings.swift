//
//  EBDisplayStrings.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 26/02/25.
//

import Foundation

/// Contains display-related string constants.
struct EBDisplayStrings {
    static let top100CoinsTitle = "Top 100 Coins"
    static let favoritesTitle = "Favorites"
    static let errorTitle = "Error"
    static let okButton = "OK"
    static let refreshButton = "Refresh"
    static let priceFilter = "Price"
    static let performanceFilter = "24H%"
    static let nameFilter = "Name"
    static let unfavoriteTitle = "Unfavorite"
    static let favoriteTitle = "Favorite"
    static let noDataMessage = "No data available"
}

/// Defines display string templates for cryptocurrency stats with placeholders for dynamic values.
enum StatDisplayString {
    // Templates for stats with placeholders (%@ for dynamic values)
    static let rank = "Rank: %@"
    static let volume24h = "24h Volume: %@"
    static let marketCap = "Market Cap: %@"
    static let listingDate = "Listing Date: %@"
    static let btcPrice = "BTC Price: %@"
    
    /// Returns the formatted string with the dynamic value.
    static func format(_ template: String, value: Any?) -> String {
        let defaultValue = value as? String ?? (value as? Int)?.description ?? "N/A"
        return String(format: template, defaultValue)
    }
}
