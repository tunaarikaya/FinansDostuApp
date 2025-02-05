import SwiftUI

//2w
struct FinansDostu: App {
    @StateObject private var viewModel = MainViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .preferredColorScheme(viewModel.isDarkMode ? .dark : .light)
        }
    }
} 
