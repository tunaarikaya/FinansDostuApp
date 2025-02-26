import SwiftUI

struct PaymentDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let payment: PlannedPayment
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text("Başlık")
                        Spacer()
                        Text(payment.title)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Tutar")
                        Spacer()
                        Text(String(format: "%.2f ₺", payment.amount))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Tarih")
                        Spacer()
                        Text(payment.dueDate.formatted(date: .long, time: .omitted))
                            .foregroundColor(.secondary)
                    }
                    
                    if let note = payment.note {
                        HStack {
                            Text("Not")
                            Spacer()
                            Text(note)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if payment.isRecurring {
                        HStack {
                            Text("Tekrarlama")
                            Spacer()
                            Text(payment.recurringInterval ?? "")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Ödemeyi Sil")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Ödeme Detayları")
            .navigationBarItems(trailing: Button("Kapat") { dismiss() })
        }
    }
} 