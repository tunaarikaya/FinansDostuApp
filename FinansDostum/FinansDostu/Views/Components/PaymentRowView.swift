import SwiftUI
import Foundation

struct PaymentRowView: View {
    let payment: PlannedPayment
    let onUpdate: (PlannedPayment) -> Void
    @ObservedObject var viewModel: MainViewModel
    @State private var showingConfirmation = false
    @State private var showingEditSheet = false
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    if !payment.isPaid {
                        showingConfirmation = true
                    }
                }) {
                    Image(systemName: payment.isPaid ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(payment.isPaid ? .green : .gray)
                        .font(.title2)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(payment.title)
                        .font(.headline)
                    if let note = payment.note {
                        Text(note)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(payment.dueDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .onTapGesture {
                    showingEditSheet = true
                }
                
                Spacer()
                
                Text(payment.amount.formattedCurrency())
                    .foregroundStyle(payment.isPaid ? .green : .primary)
                    .font(.headline)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .alert("Ödemeyi Onayla", isPresented: $showingConfirmation) {
            Button("İptal", role: .cancel) {}
            Button("Onayla") {
                viewModel.markPaymentAsCompleted(payment)
            }
        } message: {
            Text("\(payment.title) ödemesini tamamladığınızı onaylıyor musunuz?\nTutar: \(String(format: "%.2f ₺", payment.amount))")
        }
        .sheet(isPresented: $showingEditSheet) {
            EditPlannedPaymentView(payment: payment, viewModel: viewModel)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                viewModel.deletePlannedPayment(payment)
            } label: {
                Label("Sil", systemImage: "trash")
            }
        }
    }
}
