import SwiftUI

struct MainView: View {
    @StateObject var viewModel: MainViewModel
    @State private var showingAddTransaction = false
    
    var body: some View {
        TabView {
            NavigationView {
                HomeView(viewModel: viewModel)
            }
            .tabItem {
                Label("Ana Sayfa", systemImage: "house.fill")
            }
            
            NavigationView {
                GraphView(viewModel: viewModel)
            }
            .tabItem {
                Label("Grafikler", systemImage: "chart.pie.fill")
            }
            
            NavigationView {
                CalendarView(viewModel: viewModel)
            }
            .tabItem {
                Label("Takvim", systemImage: "calendar")
            }
            
            NavigationView {
                BudgetAssistantView(viewModel: viewModel)
            }
            .tabItem {
                Label("Bütçe Asistanı", systemImage: "brain.head.profile")
            }
            
            NavigationView {
                ProfileView(viewModel: viewModel)
            }
            .tabItem {
                Label("Profil", systemImage: "person.fill")
            }
        }
    }
} 
