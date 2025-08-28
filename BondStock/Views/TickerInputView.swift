//
//  TickerInputView.swift
//  BondStock
//
//  Created by Baurzhan on 8/27/25.
//

import SwiftUI

struct TickerInputView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(AppViewModel.self) var appVM: AppViewModel
    
    @Binding var selectedTab: CustomTab
    @Binding var path: [Stock]
    @State private var tickerInput = ""
    @State private var showingAlert = false
    @FocusState private var isTextFieldActive: Bool
    
    var textFieldBackground: Color {
        colorScheme == .light
        ? .gray.mix(with: .white, by: 0.8)
        : .black.mix(with: .white, by: 0.4)
    }
    
    var removeKeyboard: some Gesture {
        DragGesture()
            .onEnded { value in
                if value.translation.height < 0 { // swipe from bottom to top
                    isTextFieldActive = true
                } else if value.translation.height > 0 { // swipe from top to bottom
                    isTextFieldActive = false
                }
            }
    }
    
    var showingSearchButton: Bool {
        tickerInput.isEmpty
    }
    
    var body: some View {
        VStack {
            placeHolderText
                .offset(y: appVM.keyboardHeight)
            
            textField
                .gesture(removeKeyboard)
                .offset(y: isTextFieldActive ? 30 : 0)
        }
        .offset(y: -appVM.keyboardHeight)
        .alert("Ticker not found", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        }
        .onChange(of: selectedTab) { _, newValue in
            if newValue != .input {
                isTextFieldActive = false
            } else {
                Task {
                    try? await Task.sleep(nanoseconds: 230_000_000)
                    await MainActor.run {
                        isTextFieldActive = true
                    }
                }
            }
        }
        .animation(nil, value: appVM.keyboardHeight)
    }
    
    private var placeHolderText: some View {
        VStack(spacing: 10) {
            Text("Enter Stock Ticker")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Search for any stock symbol")
                .font(.title3)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 20)
    }
    
    private var textField: some View {
        HStack(alignment: .center, spacing: 0) {
            searchIcon
            
            TextField("e.g. AAPL, GOOGL, TSLA", text: $tickerInput)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .foregroundStyle(.primary)
                .focused($isTextFieldActive)
                .tint(.customRed)
            
            searchButton
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 60)
                .fill(textFieldBackground)
        )
        .background(
            Rectangle()
                .fill(textFieldBackground)
                .offset(y: 40)
        )
    }
    
    private var searchIcon: some View {
        Image(systemName: "magnifyingglass")
            .resizable()
            .scaledToFit()
            .bold()
            .foregroundStyle(.primary)
            .frame(height: 20)
            .padding(8)
    }
    
    private var searchButton: some View {
        Button {
            let trimmed = tickerInput
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .uppercased()
                    
            if let stock = appVM.stocks.first(where: { $0.ticker.uppercased() == trimmed }) {
                path.append(stock)
                tickerInput = ""
                isTextFieldActive = false
            } else {
                showingAlert = true
            }
        } label: {
            Image(systemName: "arrow.up.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.primary)
                .frame(height: 30)
                .padding(8)
        }
        .buttonStyle(.plain)
        .opacity(showingSearchButton ? 0 : 1)
        .animation(.easeInOut(duration: 0.15), value: showingSearchButton)
    }
}

#Preview {
    @Previewable @State var path = [Stock]()
    @Previewable @State var selectedTab = CustomTab.list
    TickerInputView(selectedTab: $selectedTab,  path: $path)
}
