import SwiftUI

struct EditPlannedPaymentView: View {
    @State var payment: PlannedPayment
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ödeme Detayları")) {
                    TextField("Başlık", text: $payment.title)
                    TextField("Tutar", value: $payment.amount, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                }
                
                Section {
                    Button(action: {
                        viewModel.deletePlannedPayment(payment)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Sil")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Ödeme Düzenle")
            .navigationBarItems(trailing: Button("Kaydet") {
                viewModel.updatePlannedPayment(payment)
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
} 