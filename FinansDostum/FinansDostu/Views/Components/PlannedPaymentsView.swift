import SwiftUI

struct PlannedPaymentsView: View {
    let payments: [PlannedPayment]
    @ObservedObject var viewModel: MainViewModel
    @State private var selectedPayment: PlannedPayment?
    @State private var isEditing: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if payments.isEmpty {
                Text("Planlı ödeme bulunmuyor")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(payments) { payment in
                    PaymentRowView(payment: payment, onUpdate: { updatedPayment in
                        viewModel.updatePlannedPayment(updatedPayment)
                    }, viewModel: viewModel)
                    .onTapGesture {
                        selectedPayment = payment
                        isEditing = true
                    }
                    
                    if payment.id != payments.last?.id {
                        Divider()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .sheet(item: $selectedPayment) { payment in
            EditPlannedPaymentView(payment: payment, viewModel: viewModel)
        }
    }
}

