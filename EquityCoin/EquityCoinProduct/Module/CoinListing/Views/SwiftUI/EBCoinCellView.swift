//
//  EBCoinCellView.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 01/03/25.
//

import SwiftUI

struct EBCoinCellView: View {
    let coin: EBCoin
    let isFavorite: Bool
    @StateObject private var imageDownloader = EBImageDownloader()
    private let imageSize: CGFloat = 30
    
    var body: some View {
        HStack {
            ZStack {
                if let uiImage = imageDownloader.image {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageSize, height: imageSize)
                } else if let svgData = imageDownloader.svgData {
                    EBSVGImageView(svgData: svgData, size: CGSize(width: imageSize, height: imageSize))
                        .frame(width: imageSize, height: imageSize)
                        .clipped()
                } else {
                    ProgressView()
                        .frame(width: imageSize, height: imageSize)
                }
            }
            .onAppear {
                imageDownloader.loadImage(from: coin.iconUrl)
            }
            .onDisappear {
                imageDownloader.cancel()
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

#Preview {
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
