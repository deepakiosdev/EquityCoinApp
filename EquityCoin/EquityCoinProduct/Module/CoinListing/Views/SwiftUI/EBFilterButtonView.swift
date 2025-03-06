//
//  EBFilterButtonView.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 26/02/25.
//

import SwiftUI

/// Manages the state for filter buttons, observable by UIKit for synchronization.
final class FilterState: ObservableObject {
    @Published var selectedFilter: FilterType = .none
    
    enum FilterType: Equatable {
        case none
        case priceAsc, priceDesc
        case performanceAsc, performanceDesc
        case nameAsc, nameDesc
    }
    
    /// Resets all filters to their initial state (unselected, upward arrow for ascending order).
    func resetFilters() {
        selectedFilter = .none
    }
}

/// Provides filter buttons for sorting the coin list, with ascending/descending indicators.
struct EBFilterButtonView: View {
    let onPriceFilter: (Bool) -> Void
    let onPerformanceFilter: (Bool) -> Void
    let onNameFilter: (Bool) -> Void
    @ObservedObject private var filterState: FilterState
    @State private var needsRefresh: Bool = false
    
    init(onPriceFilter: @escaping (Bool) -> Void, onPerformanceFilter: @escaping (Bool) -> Void, onNameFilter: @escaping (Bool) -> Void, filterState: FilterState = FilterState()) {
        self.onPriceFilter = onPriceFilter
        self.onPerformanceFilter = onPerformanceFilter
        self.onNameFilter = onNameFilter
        self.filterState = filterState
    }
    
    // Up arrow represents ascending order (from lowest to highest) and down represents descending
    var body: some View {
        HStack(spacing: 10) {
            Button(action: {
                if filterState.selectedFilter == .none {
                    filterState.selectedFilter = .priceAsc
                } else if filterState.selectedFilter == .priceAsc || filterState.selectedFilter == .priceDesc {
                    let isDescending = filterState.selectedFilter == .priceDesc
                    filterState.selectedFilter = isDescending ? .priceAsc : .priceDesc
                } else {
                    filterState.selectedFilter = .priceAsc // Reset to ascending if switching from other filters
                }
                onPriceFilter(filterState.selectedFilter == .priceAsc)
                needsRefresh = true
            }) {
                Text(filterState.selectedFilter == .priceDesc ? "\(EBDisplayStrings.priceFilter) ↓" : "\(EBDisplayStrings.priceFilter) ↑")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(filterState.selectedFilter == .priceAsc || filterState.selectedFilter == .priceDesc ? .white : .blue)
                    .frame(minWidth: 50)
                    .frame(height: 40)
                    .padding(.horizontal, 12)
                    .background(filterState.selectedFilter == .priceAsc || filterState.selectedFilter == .priceDesc ? Color.blue : Color.clear)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue, lineWidth: 1)
                    )
            }

            Button(action: {
                if filterState.selectedFilter == .none {
                    filterState.selectedFilter = .performanceAsc
                } else if filterState.selectedFilter == .performanceAsc || filterState.selectedFilter == .performanceDesc {
                    let isDescending = filterState.selectedFilter == .performanceDesc
                    filterState.selectedFilter = isDescending ? .performanceAsc : .performanceDesc
                } else {
                    filterState.selectedFilter = .performanceAsc // Reset to ascending if switching from other filters
                }
                onPerformanceFilter(filterState.selectedFilter == .performanceAsc)
                needsRefresh = true // Force UI update
            }) {
                Text(filterState.selectedFilter == .performanceDesc ? "\(EBDisplayStrings.performanceFilter) ↓" : "\(EBDisplayStrings.performanceFilter) ↑")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(filterState.selectedFilter == .performanceAsc || filterState.selectedFilter == .performanceDesc ? .white : .blue)
                    .frame(minWidth: 50)
                    .frame(height: 40)
                    .padding(.horizontal, 12)
                    .background(filterState.selectedFilter == .performanceAsc || filterState.selectedFilter == .performanceDesc ? Color.blue : Color.clear)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue, lineWidth: 1)
                    )
            }

            Button(action: {
                if filterState.selectedFilter == .none {
                    filterState.selectedFilter = .nameAsc
                } else if filterState.selectedFilter == .nameAsc || filterState.selectedFilter == .nameDesc {
                    let isDescending = filterState.selectedFilter == .nameDesc
                    filterState.selectedFilter = isDescending ? .nameAsc : .nameDesc
                } else {
                    filterState.selectedFilter = .nameAsc // Reset to ascending if switching from other filters
                }
                onNameFilter(filterState.selectedFilter == .nameAsc)
                needsRefresh = true // Force UI update
            }) {
                Text(filterState.selectedFilter == .nameDesc ? "\(EBDisplayStrings.nameFilter) ↓" : "\(EBDisplayStrings.nameFilter) ↑")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(filterState.selectedFilter == .nameAsc || filterState.selectedFilter == .nameDesc ? .white : .blue)
                    .frame(minWidth: 50)
                    .frame(height: 40)
                    .padding(.horizontal, 12)
                    .background(filterState.selectedFilter == .nameAsc || filterState.selectedFilter == .nameDesc ? Color.blue : Color.clear)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue, lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal)
        .previewDisplayName("Filter Buttons")
        .onChange(of: needsRefresh) { _ in
            needsRefresh = false // Reset after forcing update
        }
    }
}

#Preview {
    EBFilterButtonView(
        onPriceFilter: { _ in },
        onPerformanceFilter: { _ in },
        onNameFilter: { _ in }
    )
}
