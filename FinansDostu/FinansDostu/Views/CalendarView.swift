import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var selectedDate = Date()
    @State private var showingAddPayment = false
    @State private var showingPaymentDetail: PlannedPayment?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Takvim
                    DatePicker(
                        "Tarih Seçin",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                    
                    // Yaklaşan Ödemeler
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Yaklaşan Ödemeler")
                                .font(.headline)
                            Spacer()
                            Button {
                                showingAddPayment.toggle()
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.theme.accent)
                                    .font(.title2)
                            }
                        }
                        .padding(.horizontal)
                        
                        ForEach(viewModel.plannedPayments) { payment in
                            PlannedPaymentRow(payment: payment)
                                .onTapGesture {
                                    showingPaymentDetail = payment
                                }
                        }
                    }
                }
            }
            .navigationTitle("Takvim")
            .sheet(isPresented: $showingAddPayment) {
                AddPlannedPaymentView(viewModel: viewModel)
            }
            .sheet(item: $showingPaymentDetail) { payment in
                PaymentDetailView(payment: payment, viewModel: viewModel)
            }
        }
    }
}

struct PlannedPaymentRow: View {
    let payment: PlannedPayment
    
    var body: some View {
        HStack {
            // Sol taraf - Tarih
            VStack(alignment: .center) {
                Text(payment.dueDate.formatted(.dateTime.day()))
                    .font(.title2.bold())
                Text(payment.dueDate.formatted(.dateTime.month(.abbreviated)))
                    .font(.caption)
            }
            .frame(width: 50)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(daysUntilDue < 3 ? Color.red.opacity(0.1) : Color.theme.accent.opacity(0.1))
            )
            
            // Orta - Başlık ve Detay
            VStack(alignment: .leading, spacing: 4) {
                Text(payment.title)
                    .font(.headline)
                Text(payment.note ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Sağ taraf - Tutar
            VStack(alignment: .trailing) {
                Text(String(format: "%.2f ₺", payment.amount))
                    .font(.headline)
                Text(timeUntilDue)
                    .font(.caption)
                    .foregroundColor(daysUntilDue < 3 ? .red : .secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
    
    private var daysUntilDue: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: Date(), to: payment.dueDate).day ?? 0
    }
    
    private var timeUntilDue: String {
        if daysUntilDue == 0 {
            return "Bugün"
        } else if daysUntilDue == 1 {
            return "Yarın"
        } else {
            return "\(daysUntilDue) gün kaldı"
        }
    }
}

struct AddPlannedPaymentView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MainViewModel
    
    @State private var title = ""
    @State private var amount = ""
    @State private var dueDate = Date()
    @State private var note = ""
    @State private var isRecurring = false
    @State private var recurringInterval: RecurringInterval = .month
    
    enum RecurringInterval: String, CaseIterable {
        case week = "Haftalık"
        case month = "Aylık"
        case year = "Yıllık"
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ödeme Detayları")) {
                    TextField("Başlık", text: $title)
                    TextField("Tutar", text: $amount)
                        .keyboardType(.decimalPad)
                    DatePicker("Tarih", selection: $dueDate, displayedComponents: [.date])
                    TextField("Not (İsteğe bağlı)", text: $note)
                }
                
                Section(header: Text("Tekrarlama")) {
                    Toggle("Tekrarlayan Ödeme", isOn: $isRecurring)
                    
                    if isRecurring {
                        Picker("Tekrarlama Aralığı", selection: $recurringInterval) {
                            ForEach(RecurringInterval.allCases, id: \.self) { interval in
                                Text(interval.rawValue).tag(interval)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Yeni Ödeme Planı")
            .navigationBarItems(
                leading: Button("İptal") { dismiss() },
                trailing: Button("Kaydet") {
                    if let amountDouble = Double(amount), !title.isEmpty {
                        viewModel.addPlannedPayment(
                            title: title,
                            amount: amountDouble,
                            dueDate: dueDate,
                            note: note.isEmpty ? nil : note,
                            isRecurring: isRecurring,
                            recurringInterval: isRecurring ? recurringInterval : nil
                        )
                        dismiss()
                    }
                }
                .disabled(title.isEmpty || amount.isEmpty)
            )
        }
    }
} 