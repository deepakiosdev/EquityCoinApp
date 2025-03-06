//
//  EBCoinCellView.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 26/02/25.
//

import SwiftUI
import SDWebImageSwiftUI

/// Displays a single coin in a list with icon, name, price, 24h change, and favorite indicator.
struct EBCoinCellView: View {
    let coin: EBCoin
    let isFavorite: Bool
    
    var body: some View {
        HStack {
            ZStack {
                WebImage(url: URL(string: coin.iconUrl ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                    case .failure(_):
                        Image("defaultCrypto")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.gray)
                    case .empty:
                        ProgressView()
                            .frame(width: 30, height: 30)
                    @unknown default:
                        EmptyView()
                    }
                }
               .indicator(.activity)
                .transition(.fade(duration: 0.5))
            }
            
            VStack(alignment: .leading) {
                Text(coin.name).font(.headline)
                HStack(spacing: 4) {
                    if isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .imageScale(.small)
                    }
                    Text("$\(coin.price)").font(.subheadline)
                }
            }
            
            Spacer()
            
            Text("\(coin.change)%")
                .foregroundColor(coin.changeDouble >= 0 ? .green : .red)
        }
        .padding()
        .previewDisplayName("Coin Cell")
    }
}

#Preview() {
    EBCoinCellView(
        coin: EBCoin(
            id: "Qwsogvtv82FCd",
            name: "Bitcoin",
            symbol: "BTC",
            iconUrl: "https://cdn.coinranking.com/bOabBYkcX/bitcoin_btc.svg",
            price: "85000",
            change: "6.62",
            sparkline: ["85000", "85500"]
        ),
        isFavorite: true
    )
    .preferredColorScheme(.light)
}

