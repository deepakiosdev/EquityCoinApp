//
//  ChartPeriod.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 01/03/25.
//

import Foundation

/// Enum representing time periods for chart data filtering.
enum ChartPeriod {
    case hour, threeHours, twelveHours, day, week, month, threeMonths, year, threeYears, fiveYears
    
    /// Description for display in UI (e.g., button labels).
    var description: String {
        switch self {
        case .hour: return "1h"
        case .threeHours: return "3h"
        case .twelveHours: return "12h"
        case .day: return "24h"
        case .week: return "7d"
        case .month: return "30d"
        case .threeMonths: return "3m"
        case .year: return "1y"
        case .threeYears: return "3y"
        case .fiveYears: return "5y"
        }
    }
    
    /// All available time periods for iteration in UI.
    static let allPeriods: [ChartPeriod] = [.hour, .threeHours, .twelveHours, .day, .week, .month, .threeMonths, .year, .threeYears, .fiveYears]
}
