import SwiftUI

struct PlannedPaymentRow: View {
    let payment: PlannedPayment
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(payment.title)
                    .font(.headline)
                if payment.isRecurring {
                    Text("Tekrarlayan")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Text(payment.dueDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(payment.amount.formattedCurrency())
                .foregroundColor(payment.isPaid ? .green : .red)
        }
        .padding(.vertical, 4)
    }
} 
