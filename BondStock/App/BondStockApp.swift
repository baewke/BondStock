//
//  BondStockApp.swift
//  BondStock
//
//  Created by Baurzhan on 8/27/25.
//

import SwiftUI

@main
struct BondStockApp: App {
    @State private var appVM = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appVM)
        }
    }
}
