import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction
    @ObservedObject var viewModel: MainViewModel
    @State private var showingDetails = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        Button(action: { showingDetails = true }) {
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
        .sheet(isPresented: $showingDetails) {
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
                    
                    Section {
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("İşlemi Sil")
                            }
                        }
                    }
                }
                .navigationTitle(transaction.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Kapat") {
                            showingDetails = false
                        }
                    }
                }
                .alert("İşlemi Sil", isPresented: $showingDeleteAlert) {
                    Button("İptal", role: .cancel) { }
                    Button("Sil", role: .destructive) {
                        viewModel.deleteTransaction(transaction)
                        showingDetails = false
                    }
                } message: {
                    Text("Bu işlemi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.")
                }
            }
        }
    }
} 