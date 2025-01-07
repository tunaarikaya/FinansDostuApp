import SwiftUI

struct MainView: View {
    @StateObject var viewModel: MainViewModel
    @State private var showingAddTransaction = false
    
    var body: some View {
        TabView {
            NavigationView {
                VStack(alignment:.leading){
                    // Header
                    HeaderView(user: viewModel.user)
                    
                    // Balance Card
                    BalanceCardView(balance: viewModel.user.balance)
                    
                    // Search and Add Transaction
                    SearchBarView(
                        searchText: $viewModel.searchText,
                        addAction: { showingAddTransaction.toggle() }
                    )
                    
                    // Transaction List
                    TransactionListView(transactions: viewModel.filteredTransactions)
                        
                       .frame(maxWidth: .infinity, alignment: .leading) // Sola hizalama
                        .padding(.top) // Üstten boşluk
                }
                .padding()
                .sheet(isPresented: $showingAddTransaction) {
                    AddTransactionView(viewModel: viewModel)
                }
            }
            .onChange(of: viewModel.searchText) { oldValue, newValue in
                viewModel.filterTransactions()
            }
            .tabItem {
                Label("Ana Sayfa", systemImage: "house.fill")
            }
            
            GraphView(viewModel: viewModel)
                .tabItem {
                    Label("Grafikler", systemImage: "chart.pie.fill")
                }
            
            CalendarView(viewModel: viewModel)
                .tabItem {
                    Label("Takvim", systemImage: "calendar")
                }
            
            GoalsView(viewModel: viewModel)
                .tabItem {
                    Label("Hedefler", systemImage: "target")
                }
            
            ProfileView(viewModel: viewModel)
                .tabItem {
                    Label("Profil", systemImage: "person.fill")
                }
        }
    }
} 
