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
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
