import SwiftUI

struct TransactionListView: View {
    let transactions: [Transaction]
    
    var body: some View {
        List {
            ForEach(transactions) { transaction in
                TransactionRowView(transaction: transaction)
            }
        }
    }
} 
