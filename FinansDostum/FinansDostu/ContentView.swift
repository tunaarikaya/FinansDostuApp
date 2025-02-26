//
//  ContentView.swift
//  FinansDostu
//
//  Created by Mehmet Tuna Arıkaya on 6.01.2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = MainViewModel()

    var body: some View {
        MainView(viewModel: viewModel)
            .environment(\.managedObjectContext, viewContext)
            .task {
                // UI hazır olduktan sonra ağır işlemleri başlat
                await loadInitialData()
            }
    }
    
    private func loadInitialData() async {
        // Ağır işlemleri arka planda yap
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await viewModel.loadTransactions()
            }
            group.addTask {
                await viewModel.loadPlannedPayments()
            }
        }
    }
}
