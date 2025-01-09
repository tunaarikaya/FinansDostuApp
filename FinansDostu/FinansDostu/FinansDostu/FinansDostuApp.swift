//
//  FinansDostuApp.swift
//  FinansDostu
//
//  Created by Mehmet Tuna Arıkaya on 6.01.2025.
//

import SwiftUI

@main
struct FinansDostuApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var viewModel = MainViewModel()
    
    init() {
        // Varsayılan tema ayarını koyu olarak ayarla
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            UserDefaults.standard.set(true, forKey: "isDarkMode")
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(viewModel)
                .preferredColorScheme(viewModel.isDarkMode ? .dark : .light)
        }
    }
}
