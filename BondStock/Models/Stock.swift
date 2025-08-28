//
//  Stock.swift
//  BondStock
//
//  Created by Baurzhan on 8/27/25.
//

import Foundation

struct Stock: Identifiable, Hashable {
    let id = UUID()
    let ticker: String
    let name: String
}
