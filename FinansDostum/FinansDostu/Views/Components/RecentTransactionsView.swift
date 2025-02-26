import SwiftUI

struct RecentTransactionsView: View {
    let transactions: [Transaction]
    let viewModel: MainViewModel
    @Binding var selectedTransaction: Transaction?
    @Binding var showingTransactionDetails: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(transactions.prefix(25)) { transaction in
                Button(action: {
                    selectedTransaction = transaction
                    showingTransactionDetails = true
                }) {
                    TransactionRowView(transaction: transaction, viewModel: viewModel)
                }
                
                if transaction.id != transactions.prefix(5).last?.id {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.subheadline)
                Text(transaction.category)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(transaction.amount.formattedCurrency())
                .foregroundStyle(transaction.type == .expense ? .red : .green)
                .fontWeight(.medium)
        }
        .padding(.vertical, 4)
    }
} 
