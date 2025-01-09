import SwiftUI

struct FinansDostu: App {
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
                .environmentObject(viewModel)
                .preferredColorScheme(viewModel.isDarkMode ? .dark : .light)
        }
    }
} 
