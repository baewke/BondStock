//
//  StockDetailView.swift
//  BondStock
//
//  Created by Baurzhan on 8/27/25.
//

import SwiftUI

struct StockDetailView: View {
    let stock: Stock
    @Environment(AppViewModel.self) var appVM: AppViewModel
    @State private var isViewVisible = true
    
    private var buttonText: String {
        appVM.manuallyDisabled[stock.ticker] == true ? "Enable Polling" : "Disable Polling"
    }
    
    private var buttonColor: Color {
        appVM.manuallyDisabled[stock.ticker] == true ? .green : .red
    }
    
    var body: some View {
        VStack(spacing: 30) {
            tickerAndName
            
            priceLabel
            
            VStack(spacing: 15) {
                pollingStatusLabel
                
                pollingToggleButton
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            appVM.handleVisibilityChange(for: stock.ticker, isVisible: true)
        }
        .onDisappear {
            appVM.handleVisibilityChange(for: stock.ticker, isVisible: false)
        }
    }
    
    private var tickerAndName: some View {
        VStack(spacing: 10) {
            Text(stock.ticker)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(stock.name)
                .font(.title2)
                .foregroundColor(.secondary)
        }
    }
    
    private var priceLabel: some View {
        VStack(spacing: 15) {
            Text("Current Price")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("$\(appVM.prices[stock.ticker] ?? 0)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
        }
    }
    
    private var pollingStatusLabel: some View {
        HStack {
            Circle()
                .fill(appVM.pollingColor(for: stock.ticker))
                .frame(width: 12, height: 12)
            
            Text("Status: \(appVM.pollingStatus(for: stock.ticker))")
                .font(.headline)
        }
    }
    
    private var pollingToggleButton: some View {
        Button {
            appVM.toggleManualPolling(for: stock.ticker)
        } label: {
            Text(buttonText)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(buttonColor)
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}

#Preview {
    StockDetailView(stock: Stock(ticker: "", name: ""))
}
