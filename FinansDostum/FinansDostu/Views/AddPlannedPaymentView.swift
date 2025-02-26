import SwiftUI

struct AddPlannedPaymentView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MainViewModel
    
    @State private var title = ""
    @State private var amount = ""
    @State private var isRecurring = false
    @State private var recurringInterval = "month"
    @State private var note = ""
    @State private var selectedDate = Date()
    @State private var notificationPreferences = NotificationPreference()
    
    private var isValidAmount: Bool {
        guard let amount = Double(amount) else { return false }
        return !amount.isNaN && amount.isFinite // 0 TL'ye izin veriyoruz
    }
    
    private var canSave: Bool {
        !title.isEmpty && isValidAmount // Sadece başlık kontrolü ve geçerli sayı kontrolü
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ödeme Detayları")) {
                    TextField("Başlık", text: $title)
                        .textInputAutocapitalization(.words)
                    
                    HStack {
                        ZStack(alignment: .leading) {
                            if amount.isEmpty {
                                Text("Tutar (daha sonra düzenlenebilir)")
                                    .foregroundStyle(.secondary)
                                    .font(.body)
                            }
                            TextField("", text: $amount)
                                .keyboardType(.decimalPad)
                                .onChange(of: amount) { newValue in
                                    // Sadece sayı ve nokta girişine izin ver
                                    let filtered = newValue.filter { "0123456789.".contains($0) }
                                    if filtered != newValue {
                                        amount = filtered
                                    }
                                    // En fazla bir nokta olabilir
                                    if filtered.filter({ $0 == "." }).count > 1 {
                                        amount = String(filtered.prefix(while: { $0 != "." })) + "."
                                    }
                                }
                        }
                        Text("₺")
                    }
                    
                    DatePicker("Ödeme Tarihi", selection: $selectedDate, displayedComponents: [.date])
                        .datePickerStyle(.compact)
                        .environment(\.locale, Locale(identifier: "tr_TR"))
                    
                    Toggle("Tekrarlayan Ödeme", isOn: $isRecurring)
                    
                    if isRecurring {
                        Picker("Tekrarlama Aralığı", selection: $recurringInterval) {
                            Text("Aylık").tag("month")
                            Text("Haftalık").tag("week")
                            Text("Yıllık").tag("year")
                        }
                    }
                }
                
                Section(header: Text("Bildirimler")) {
                    Toggle("1 Gün Önce", isOn: $notificationPreferences.oneDay)
                    Toggle("3 Gün Önce", isOn: $notificationPreferences.threeDays)
                    Toggle("1 Hafta Önce", isOn: $notificationPreferences.oneWeek)
                }
                
                Section(header: Text("Ek Bilgiler")) {
                    TextField("Not (İsteğe bağlı)", text: $note)
                        .textInputAutocapitalization(.sentences)
                }
            }
            .navigationTitle("Planlı Ödeme Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        savePayment()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
    
    private func savePayment() {
        let amountValue = Double(amount) ?? 0 // Boş veya geçersiz ise 0 kullan
        
        let payment = PlannedPayment(
            id: UUID(),
            title: title,
            amount: amountValue,
            dueDate: selectedDate,
            isPaid: false,
            note: note.isEmpty ? nil : note,
            notificationPreferences: notificationPreferences,
            isRecurring: isRecurring,
            recurringInterval: isRecurring ? recurringInterval : nil
        )
        
        viewModel.addPlannedPayment(
            title: title,
            amount: amountValue,
            dueDate: selectedDate,
            note: note.isEmpty ? nil : note,
            isRecurring: isRecurring,
            recurringInterval: isRecurring ? recurringInterval : nil
        )
        
        // Bildirimleri planla
        if notificationPreferences.oneDay || notificationPreferences.threeDays || notificationPreferences.oneWeek {
            viewModel.schedulePaymentNotifications(for: payment)
        }
        
        dismiss()
    }
}
