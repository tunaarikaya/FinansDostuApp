import SwiftUI

struct TransactionListView: View {
    let transactions: [TransactionEntity]
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        List {
            ForEach(transactions) { transaction in
                TransactionRowView(transaction: Transaction(from: transaction), viewModel: viewModel)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            viewContext.delete(transaction)
                            try? viewContext.save()
                        } label: {
                            Label("Sil", systemImage: "trash")
                        }
                    }
            }
        }
    }
} 
