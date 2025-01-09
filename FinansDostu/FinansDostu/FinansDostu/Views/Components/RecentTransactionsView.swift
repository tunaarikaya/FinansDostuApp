import SwiftUI

struct RecentTransactionsView: View {
    let transactions: [Transaction]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Son İşlemler")
                .font(.headline)
            
            ForEach(transactions.prefix(5)) { transaction in
                TransactionRow(transaction: transaction)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(transaction.title)
                    .font(.subheadline)
                Text(transaction.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(String(format: "%.2f ₺", transaction.amount))
                .foregroundColor(transaction.type == .expense ? .red : .green)
        }
    }
} 