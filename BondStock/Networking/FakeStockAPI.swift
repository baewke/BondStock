//
//  FakeStockAPI.swift
//  BondStock
//
//  Created by Baurzhan on 8/27/25.
//

import Foundation

class FakeStockAPI {
    static let shared = FakeStockAPI()
    private var callCounts: [String: Int] = [:]
    private let queue = DispatchQueue(label: "FakeStockAPI")
    
    private init() {}
    
    /// Simulates a network call to fetch a ticker's price.
    /// The "price" is just how many times this ticker has been requested.
    func fetchPrice(for ticker: String, completion: @escaping (Int) -> Void) {
        queue.asyncAfter(deadline: .now() + 0.2) { // simulate network delay
            let count = (self.callCounts[ticker] ?? 0) + 1
            self.callCounts[ticker] = count
            completion(count)
        }
    }
    
    /// For testing / reset between runs
    func reset() {
        callCounts.removeAll()
    }
}
