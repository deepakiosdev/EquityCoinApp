//
//  EBAPIConstants.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 26/02/25.
//

import Foundation

/// Contains API-related constants.
struct EBAPIConstants {
    static let baseURL = "https://api.coinranking.com"
    static let keyHeaderToken = "x-access-token"
    
    static let favoritesKey = "favorites"
    static let defaultChartPeriod = "24h"
    
    // Valid time periods for history API
    static let validTimePeriods: [String] = ["1h", "3h", "12h", "24h", "7d", "30d", "3m", "1y", "3y", "5y"]
    
}
