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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
