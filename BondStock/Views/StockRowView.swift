//
//  RowView.swift
//  BondStock
//
//  Created by Baurzhan on 8/27/25.
//

import SwiftUI

struct StockRowView: View {
    @Environment(AppViewModel.self) var appVM: AppViewModel
    @State private var isVisible = false
    
    let stock: Stock
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack {
                tickerAndName
                
                Spacer()
                
                priceAndStatus
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
        }
        .buttonStyle(.plain)
        .highPriorityGesture(
            LongPressGesture(minimumDuration: 0.5)
                .onEnded { _ in
                    appVM.toggleManualPolling(for: stock.ticker)
                }
        )
        .onAppear {
            appVM.handleVisibilityChange(for: stock.ticker, isVisible: true)
        }
        .onDisappear {
            appVM.handleVisibilityChange(for: stock.ticker, isVisible: false)
        }
    }
    
    private var tickerAndName: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(stock.ticker)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(stock.name)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var priceAndStatus: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text("$\(appVM.prices[stock.ticker] ?? 0)")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            statusLabel
        }
    }
    
    private var statusLabel: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(appVM.pollingColor(for: stock.ticker))
                .frame(width: 8, height: 8)
            
            Text(appVM.pollingStatus(for: stock.ticker))
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    StockRowView(stock: Stock(ticker: "", name: ""), onTap: {})
}
