//
//  ContentView.swift
//  BondStock
//
//  Created by Baurzhan on 8/27/25.
//

import SwiftUI

// MARK: - CustomTab

enum CustomTab: String, CaseIterable {
    case list = "Stocks"
    case input = "Search"
}


// MARK: - ContentView

struct ContentView: View {
    @Environment(AppViewModel.self) var appVM: AppViewModel
    @State private var selectedTab = CustomTab.list
    @State private var path: [Stock] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                TopTabBarView(selectedTab: $selectedTab)
                
                tabView
            }
            .navigationDestination(for: Stock.self) { stock in
                StockDetailView(stock: stock)
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .ignoresSafeArea(edges: .bottom)
        }
        .onChange(of: selectedTab) { _, newValue in
            if newValue == .list {
                appVM.setStocksTabActive(true)
            } else {
                appVM.setStocksTabActive(false)
            }
        }
        .onChange(of: path) { _, newPath in
            if newPath.isEmpty {
                appVM.setIsDetailActive(false)
            } else {
                appVM.setIsDetailActive(true)
            }
        }
    }
    
    private var tabView: some View {
        TabView(selection: $selectedTab) {
            StockListView(path: $path)
                .tag(CustomTab.list)
            
            TickerInputView(selectedTab: $selectedTab, path: $path)
                .tag(CustomTab.input)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut, value: selectedTab)
    }
}

#Preview {
    ContentView()
}
