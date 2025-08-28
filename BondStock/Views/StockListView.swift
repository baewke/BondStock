//
//  list.swift
//  BondStock
//
//  Created by Baurzhan on 8/27/25.
//

import SwiftUI

struct StockListView: View {
    @Environment(AppViewModel.self) var appVM: AppViewModel
    @Binding var path: [Stock]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                ForEach(appVM.stocks) { stock in
                    StockRowView(stock: stock) {
                        path.append(stock)
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var path = [Stock]()
    StockListView(path: $path)
}
