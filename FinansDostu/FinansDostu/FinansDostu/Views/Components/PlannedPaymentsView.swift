import SwiftUI

struct PlannedPaymentsView: View {
    let payments: [PlannedPayment]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Planlı Ödemeler")
                .font(.headline)
            
            if payments.isEmpty {
                Text("Planlı ödeme bulunmuyor")
                    .foregroundColor(.secondary)
            } else {
                ForEach(payments) { payment in
                    PlannedPaymentRow(payment: payment)
                    
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
        .shadow(radius: 2)
    }
}

