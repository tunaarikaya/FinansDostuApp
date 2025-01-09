import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MainViewModel
    
    @State private var title = ""
    @State private var amount = ""
    @State private var type: Transaction.TransactionType = .expense
    @State private var category = "Diğer"
    @State private var note = ""
    @State private var date = Date()
    @State private var isShowingCategories = false
    
    let categories = [
        "Market", "Faturalar", "Ulaşım", "Sağlık", 
        "Eğlence", "Alışveriş", "Maaş", "Ek Gelir", "Diğer"
    ]
    
    private var previewAmount: String {
        guard let amountDouble = Double(amount) else { return "0.00 ₺" }
        let prefix = type == .expense ? "-" : "+"
        return "\(prefix)\(String(format: "%.2f ₺", abs(amountDouble)))"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Tutar Girişi
                        VStack(spacing: 8) {
                            Text(previewAmount)
                                .font(.system(size: 44, weight: .bold, design: .rounded))
                                .foregroundStyle(type == .expense ? .red : .green)
                                .animation(.spring(), value: type)
                                .frame(height: 60)
                            
                            // Gelir/Gider Seçici
                            Picker("", selection: $type) {
                                Text("Gider").tag(Transaction.TransactionType.expense)
                                Text("Gelir").tag(Transaction.TransactionType.income)
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal, 50)
                        }
                        .padding(.vertical)
                        
                        // İşlem Detayları
                        VStack(spacing: 16) {
                            // Tutar TextField
                            HStack {
                                Image(systemName: "turkishlirasign.circle.fill")
                                    .foregroundStyle(.blue)
                                    .font(.title2)
                                TextField("0.00", text: $amount)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .font(.title3)
                            }
                            .padding()
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            // Başlık TextField
                            HStack {
                                Image(systemName: "text.alignleft")
                                    .foregroundStyle(.blue)
                                    .font(.title2)
                                TextField("Başlık", text: $title)
                                    .font(.title3)
                            }
                            .padding()
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            // Kategori Seçici
                            Button(action: { isShowingCategories.toggle() }) {
                                HStack {
                                    Image(systemName: "tag.fill")
                                        .foregroundStyle(.blue)
                                        .font(.title2)
                                    Text(category)
                                        .font(.title3)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.gray)
                                }
                                .padding()
                                .background(Color(.secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            // Tarih Seçici
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundStyle(.blue)
                                    .font(.title2)
                                DatePicker("", selection: $date, displayedComponents: [.date])
                                    .labelsHidden()
                            }
                            .padding()
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            // Not TextField
                            HStack {
                                Image(systemName: "note.text")
                                    .foregroundStyle(.blue)
                                    .font(.title2)
                                TextField("Not (İsteğe bağlı)", text: $note)
                                    .font(.title3)
                            }
                            .padding()
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal)
                        
                        // Kaydet Butonu
                        Button(action: saveTransaction) {
                            Text("Kaydet")
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(canSave ? .blue : .gray)
                                )
                                .padding(.horizontal)
                                .padding(.top)
                        }
                        .disabled(!canSave)
                    }
                }
            }
            .navigationTitle("Yeni İşlem")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $isShowingCategories) {
                CategoryPickerView(selectedCategory: $category)
            }
        }
    }
    
    private var canSave: Bool {
        !title.isEmpty && !amount.isEmpty && Double(amount) != nil
    }
    
    private func saveTransaction() {
        if let amountDouble = Double(amount), !title.isEmpty {
            viewModel.addTransaction(
                title: title,
                amount: amountDouble,
                type: type,
                category: category,
                date: date,
                note: note.isEmpty ? nil : note
            )
            dismiss()
        }
    }
}

struct CategoryPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCategory: String
    
    let categories = [
        "Market", "Faturalar", "Ulaşım", "Sağlık", 
        "Eğlence", "Alışveriş", "Maaş", "Ek Gelir", "Diğer"
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                        dismiss()
                    }) {
                        HStack {
                            Text(category)
                                .foregroundStyle(.primary)
                            Spacer()
                            if category == selectedCategory {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Kategori Seç")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }
} 