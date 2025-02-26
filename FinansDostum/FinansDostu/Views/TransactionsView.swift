import SwiftUI
import Foundation


struct TransactionsView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var showingDeleteAlert = false
    @State private var transactionToDelete: Transaction?
    @State private var selectedTransaction: Transaction?
    @State private var showingTransactionDetails = false
    
    var body: some View {
        List {
            ForEach(viewModel.transactions) { transaction in
                Button(action: {
                    selectedTransaction = transaction
                    showingTransactionDetails = true
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(transaction.title)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text(transaction.category)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(transaction.amount.formattedCurrency())
                            .foregroundStyle(transaction.type == .expense ? .red : .green)
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        transactionToDelete = transaction
                        showingDeleteAlert = true
                    } label: {
                        Label("Sil", systemImage: "trash")
                    }
                }
            }
            .onDelete(perform: deleteTransaction)
        }
        .listStyle(.insetGrouped)
        .sheet(isPresented: $showingTransactionDetails) {
            if let transaction = selectedTransaction {
                NavigationView {
                    List {
                        Section {
                            HStack {
                                Text("Tutar")
                                Spacer()
                                Text(transaction.amount.formattedCurrency())
                                    .foregroundStyle(transaction.type == .expense ? .red : .green)
                            }
                            
                            HStack {
                                Text("Kategori")
                                Spacer()
                                Text(transaction.category)
                                    .foregroundStyle(.secondary)
                            }
                            
                            HStack {
                                Text("Tarih")
                                Spacer()
                                Text(transaction.date.formatted(date: .long, time: .omitted))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        if let note = transaction.note, !note.isEmpty {
                            Section(header: Text("Notunuz")) {
                                Text(note)
                                    .foregroundStyle(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 8)
                            }
                        }
                    }
                    .navigationTitle(transaction.title)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Kapat") {
                                showingTransactionDetails = false
                            }
                        }
                    }
                }
            }
        }
        .alert("İşlemi Sil", isPresented: $showingDeleteAlert) {
            Button("İptal", role: .cancel) {}
            Button("Sil", role: .destructive) {
                if let transaction = transactionToDelete {
                    viewModel.deleteTransaction(transaction)
                }
            }
        } message: {
            Text("Bu işlemi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.")
        }
    }
    
    private func deleteTransaction(at offsets: IndexSet) {
        for index in offsets {
            let transaction = viewModel.transactions[index]
            viewModel.deleteTransaction(transaction)
        }
    }
} 
