import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var showingAddTransaction = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Karşılama Başlığı
            HStack(spacing: 12) {
                // Profil Fotosu
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.blue)
                    .background(
                        Circle()
                            .fill(.white)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tuna Arıkaya")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text("Hoş Geldiniz")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 16)
            
            // Bakiye Kartı
            BalanceCard(balance: viewModel.user.balance)
                .padding(.horizontal)
                .padding(.bottom, 8)
            
            Divider()
                .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Son İşlemler
                    RecentTransactionsView(transactions: viewModel.transactions)
                    
                    // Planlı Ödemeler
                    PlannedPaymentsView(payments: viewModel.plannedPayments)
                    
                    // Bütçe Özeti
                    BudgetSummaryView(insights: viewModel.categoryInsights)
                }
                .padding()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddTransaction = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.tint)
                }
            }
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView(viewModel: viewModel)
        }
    }
} 