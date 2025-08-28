//
//  TopTabBar.swift
//  BondStock
//
//  Created by Baurzhan on 8/27/25.
//

import SwiftUI

struct TopTabBar: View {
    @Environment(AppViewModel.self) var appVM: AppViewModel
    @Binding var selectedTab: CustomTab
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                let tabWidth = geometry.size.width / CGFloat(CustomTab.allCases.count)
                let index = CustomTab.allCases.firstIndex(of: selectedTab) ?? 0
                
                HStack {
                    ForEach(CustomTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .onTapGesture {
                                selectedTab = tab
                            }
                    }
                }
                .padding(.vertical, 8)
                .overlay(alignment: .bottomLeading) {
                    Rectangle()
                        .fill(Color.customPurple)
                        .frame(width: 30, height: 3)
                        .offset(
                            x: tabWidth * CGFloat(index) + (tabWidth - 30) / 2
                        )
                        .animation(.easeInOut, value: selectedTab)
                }
            }
            .frame(height: 50)
            
            Divider()
        }
    }
}

#Preview {
    @Previewable @State var prev = CustomTab.list
    TopTabBar(selectedTab: $prev)
}
