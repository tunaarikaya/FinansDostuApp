import SwiftUI

struct TransactionListView: View {
    let transactions: [Transaction]
    
    var body: some View {
        if transactions.isEmpty {
            Text("Henüz işlem bulunmuyor")
                .foregroundColor(.secondary)
                .padding()
        } else {
            ScrollView {
                LazyVStack(alignment:.leading, spacing: 3) {
                    ForEach(transactions) { transaction in
                        TransactionRowView(transaction: transaction)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }  .frame(maxWidth: .infinity, alignment: .leading)

        }
    }
}

struct TransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(alignment:.center) {
            // İşlem türü ikonu
            ZStack {
                Circle()
                    .fill(transaction.type == .income ? Color.theme.green.opacity(0.2) : Color.theme.red.opacity(0.2))
                    .frame(width: 45, height: 45)
                
                Image(systemName: transaction.type == .income ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                    .font(.title2)
                    .foregroundColor(transaction.type == .income ? .theme.green : .theme.red)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.headline)
                Text(transaction.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Text(transaction.type == .income ? "+" : "-")
                    .font(.headline)
                    .foregroundColor(transaction.type == .income ? .theme.green : .theme.red)
                Text(String(format: "%.2f ₺", abs(transaction.amount)))
                    .font(.headline)
                    .foregroundColor(transaction.type == .income ? .theme.green : .theme.red)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
} 
