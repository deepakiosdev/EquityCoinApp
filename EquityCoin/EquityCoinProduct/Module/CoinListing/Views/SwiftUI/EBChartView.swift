//
//  EBChartView.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 04/03/25.
//


import SwiftUI
import Charts
import Foundation

/// Displays a simplified cryptocurrency price chart for a coin in the detail screen, with a mountain-style design.
struct EBChartView: View {
    private let data: [Double]
    private let coin: EBCoin
    private let isFavorite: Bool
    private let toggleFavorite: (String) -> Void

    @State private var localIsFavorite: Bool
    init(data: [Double], coin: EBCoin,
         isFavorite: Bool,
         toggleFavorite: @escaping (String) -> Void) {
        self.data = data
        self.coin = coin
        self.isFavorite = isFavorite
        self.toggleFavorite = toggleFavorite
        self._localIsFavorite = State(initialValue: isFavorite)
    }
    
    var body: some View {
        ZStack {
            if data.isEmpty {
                Text(EBDisplayStrings.noDataMessage)
                    .foregroundColor(.gray)
                    .frame(height: 300)
            } else {
                chartView
                    .overlay(chartOverlay, alignment: .topLeading)
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: 300)
        .background(Color(.systemBackground))
        .previewDisplayName("Detail Chart View")
        .onChange(of: isFavorite) { newValue in
            // Sync local state with parent state when it changes
            localIsFavorite = newValue
        }
    }
    
    // Extract data transformations into separate properties for clarity and performance
    private var xValues: [Int] { Array(0..<data.count) }
    private var yValues: [Double] { data }
    private var minYValue: Double { yValues.min() ?? 0 }
    private var maxYValue: Double { yValues.max() ?? 0 }
    
    private var chartView: some View {
        Chart {
            ForEach(xValues, id: \.self) { index in
                AreaMark(
                    x: .value("Time", index),
                    yStart: .value("Low", minYValue),
                    yEnd: .value("High", yValues[index])
                )
                .foregroundStyle(.green.opacity(0.2))
                .interpolationMethod(.catmullRom)
                
                LineMark(
                    x: .value("Time", index),
                    y: .value("Price", yValues[index])
                )
                .foregroundStyle(.green)
                .lineStyle(StrokeStyle(lineWidth: 1))
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartYScale(domain: minYValue...maxYValue) // Lock y-axis to start from bottom
        .frame(width: UIScreen.main.bounds.width, height: 300)
    }
    
    @ViewBuilder
    private var heartButton: some View {
        Button(action: {
            // Toggle the local state and notify the parent
            localIsFavorite.toggle()
            toggleFavorite(coin.id)
        }) {
            Image(systemName: localIsFavorite ? "heart.fill" : "heart")
                .foregroundColor(.primary)
                .imageScale(.large)
                .padding(.trailing, 16)
        }
    }
    
    private var chartOverlay: some View {
        HStack {
            heartButton
        }
        .padding(.top, 8)
        .frame(height: 50)
        .frame(
            maxWidth: .infinity,
            alignment: .trailing)
    }
}


struct EBChartView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock data for preview
        let mockCoin = EBCoin(
            id: "Qwsogvtv82FCd",
            name: "Bitcoin",
            symbol: "BTC",
            iconUrl: "https://cdn.coinranking.com/bOabBYkcX/bitcoin_btc.svg",
            price: "85000",
            change: "6.62",
            sparkline: ["85000", "85500"]
        )
        
        // Preview wrapper to manage state
        PreviewWrapper(coin: mockCoin, isFavorite: false)
            .previewDisplayName("Light Mode")
            .preferredColorScheme(.light)
        
        PreviewWrapper(coin: mockCoin, isFavorite: true)
            .previewDisplayName("Dark Mode")
            .preferredColorScheme(.dark)
    }
    
    // Separate struct to manage state for the preview
    struct PreviewWrapper: View {
        let coin: EBCoin
        @State private var isFavorite: Bool
        
        init(coin: EBCoin, isFavorite: Bool) {
            self.coin = coin
            self._isFavorite = State(initialValue: isFavorite)
        }
        
        var body: some View {
            EBChartView(
                data: (80000...85000).map { Double($0) }, // Mock price data
                coin: coin,
                isFavorite: isFavorite,
                toggleFavorite: { coinId in
                    // Handle the favorite toggle in the preview
                    isFavorite.toggle()
                    print("Preview toggleFavorite called for coin \(coinId), isFavorite: \(isFavorite)")
                }
            )
        }
    }
}
