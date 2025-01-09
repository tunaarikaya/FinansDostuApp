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
    
    private var isValidAmount: Bool {
        guard let amount = Double(amount) else { return false }
        return amount > 0 && !amount.isNaN && amount.isFinite
    }
    
    private var canSave: Bool {
        !title.isEmpty && isValidAmount
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ödeme Detayları")) {
                    TextField("Başlık", text: $title)
                        .textInputAutocapitalization(.words)
                    
                    HStack {
                        TextField("Tutar", text: $amount)
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
                
                Section(header: Text("Ek Bilgiler")) {
                    TextField("Not (İsteğe bağlı)", text: $note)
                        .textInputAutocapitalization(.sentences)
                }
            }
            .navigationTitle("Yeni Planlı Ödeme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        savePayment()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
    
    private func savePayment() {
        guard let amountDouble = Double(amount), isValidAmount else { return }
        
        viewModel.addPlannedPayment(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            amount: amountDouble,
            dueDate: selectedDate,
            note: note.isEmpty ? nil : note.trimmingCharacters(in: .whitespacesAndNewlines),
            isRecurring: isRecurring,
            recurringInterval: isRecurring ? recurringInterval : nil
        )
        
        dismiss()
    }
} 