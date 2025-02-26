import SwiftUI

struct EditTransactionView: View {
    @State var transaction: Transaction
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("İşlem Detayları")) {
                    TextField("Başlık", text: $transaction.title)
                    TextField("Tutar", value: $transaction.amount, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                }
                
                Section {
                    Button(action: {
                        viewModel.deleteTransaction(transaction)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Sil")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("İşlem Düzenle")
            .navigationBarItems(trailing: Button("Kaydet") {
                viewModel.updateTransaction(transaction)
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
} 