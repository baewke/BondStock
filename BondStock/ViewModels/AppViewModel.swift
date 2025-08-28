//
//  AppViewModel.swift
//  BondStock
//
//  Created by Baurzhan on 8/27/25.
//

import Combine
import Foundation
import SwiftUI

/// Global ViewModel throughout the app.
@Observable
class AppViewModel {
    var stocks: [Stock] = [
        Stock(ticker: "AAPL", name: "Apple Inc."),
        Stock(ticker: "GOOGL", name: "Alphabet Inc."),
        Stock(ticker: "MSFT", name: "Microsoft Corp."),
        Stock(ticker: "AMZN", name: "Amazon.com Inc."),
        Stock(ticker: "TSLA", name: "Tesla Inc."),
        Stock(ticker: "META", name: "Meta Platforms Inc."),
        Stock(ticker: "NVDA", name: "NVIDIA Corp."),
        Stock(ticker: "NFLX", name: "Netflix Inc."),
        Stock(ticker: "ADBE", name: "Adobe Inc."),
        Stock(ticker: "CRM", name: "Salesforce Inc."),
        Stock(ticker: "ORCL", name: "Oracle Corp."),
        Stock(ticker: "INTC", name: "Intel Corp."),
        Stock(ticker: "AMD", name: "Advanced Micro Devices"),
        Stock(ticker: "PYPL", name: "PayPal Holdings"),
        Stock(ticker: "UBER", name: "Uber Technologies"),
        Stock(ticker: "SPOT", name: "Spotify Technology"),
        Stock(ticker: "ZOOM", name: "Zoom Video Communications"),
        Stock(ticker: "SNAP", name: "Snap Inc."),
        Stock(ticker: "TWTR", name: "Twitter Inc."),
        Stock(ticker: "SQ", name: "Block Inc.")
    ]
    
    var prices: [String: Int] = [:]
    var manuallyDisabled: [String: Bool] = [:]
    
    /// Tracks how many views showing this ticker are currently visible.
    /// Unlike the old true/false approach, we increment on appear and
    /// decrement on disappear. Polling continues as long as the count > 0.
    /// This avoids race conditions where a row disappears *after* a detail appears.
    private var visibleCounts: [String: Int] = [:]
    
    /// One global timer instead of per-ticker timers.
    private var timer: Timer?
    
    private var isStocksTabActive = true
    private var isDetailActive = false
    
    var isPollingActive: Bool {
        isStocksTabActive || isDetailActive
    }
    
    private let api = FakeStockAPI.shared
    
    // for navigation:
    var selectedStock: Stock?
    var showStockDetail = false
    
    // for textField keyboard:
    // (since we are using ignoreSafeArea.bottom for the whole app, we
    // need to manually calculate the keyboard height to move the textField up)
    var keyboardHeight = CGFloat.zero
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Initialize all stocks as enabled for polling
        for stock in stocks {
            manuallyDisabled[stock.ticker] = false
            prices[stock.ticker] = 0
            visibleCounts[stock.ticker] = 0
        }
        startGlobalTimer()
        
        addKeyboardObservers()
    }
    
    private func startGlobalTimer() {
        stopGlobalTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    private func stopGlobalTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func tick() {
        guard isPollingActive else { return }  // stop updating if tab not active
        
        for (ticker, count) in visibleCounts {
            if count > 0, manuallyDisabled[ticker] != true {
                api.fetchPrice(for: ticker) { [weak self] price in
                    DispatchQueue.main.async {
                        self?.prices[ticker] = price
                    }
                }
            }
        }
    }
    
    private func addKeyboardObservers() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map { $0.height }
            .sink { [weak self] height in
                self?.keyboardHeight = height
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
            .sink { [weak self] _ in
                self?.keyboardHeight = 0
            }
            .store(in: &cancellables)
    }
    
    func setStocksTabActive(_ active: Bool) {
        isStocksTabActive = active
    }
    
    func setIsDetailActive(_ active: Bool) {
        isDetailActive = active
    }
    
    func toggleManualPolling(for ticker: String) {
        let disabled = manuallyDisabled[ticker] ?? false
        manuallyDisabled[ticker] = !disabled
    }
    
    func handleVisibilityChange(for ticker: String, isVisible: Bool) {
        let current = visibleCounts[ticker] ?? 0
        let newCount = max(0, current + (isVisible ? 1 : -1))
        visibleCounts[ticker] = newCount
    }
    
    func isPolling(_ ticker: String) -> Bool {
        (visibleCounts[ticker] ?? 0) > 0 && manuallyDisabled[ticker] != true
    }
    
    func pollingColor(for ticker: String) -> Color {
        if manuallyDisabled[ticker] == true {
            return .red
        } else if isPolling(ticker) {
            return .green
        } else {
            return .gray
        }
    }
    
    func pollingStatus(for ticker: String) -> String {
        if manuallyDisabled[ticker] == true {
            return "Disabled"
        } else if isPolling(ticker) {
            return "Polling"
        } else {
            return "Stopped"
        }
    }
}
