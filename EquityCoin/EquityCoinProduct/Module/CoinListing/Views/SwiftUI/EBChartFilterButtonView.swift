//
//  EBChartFilterButtonView.swift
//  EquityCoin
//
//  Created by Dipak Kumar Pandey on 26/02/25.
//

import SwiftUI

struct EBChartFilterButtonView: View {
    let onFilter: (ChartPeriod) -> Void
    @State private var selectedPeriod: ChartPeriod? = nil

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(ChartPeriod.allPeriods, id: \.self) { period in
                    Button(action: {
                        selectedPeriod = period
                        onFilter(period)
                        print("Chart Filter Button tapped: \(period.description)")
                    }) {
                        Text(period.description)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(selectedPeriod == period ? .white : .blue)
                            .frame(minWidth: 50)
                            .frame(height: 40)
                            .padding(.horizontal, 12)
                            .background(selectedPeriod == period ? Color.blue : Color.clear)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 10)
        }
    }
}
struct EBChartFilterButtonView_Previews: PreviewProvider {
    static var previews: some View {
        EBChartFilterButtonView { period in
            print("Filter applied for period: \(period.description)")
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}

