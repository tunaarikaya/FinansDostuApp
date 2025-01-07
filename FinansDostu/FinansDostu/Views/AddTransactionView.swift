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
    
    let categories = [
        "Market", "Faturalar", "Ulaşım", "Sağlık", 
        "Eğlence", "Alışveriş", "Maaş", "Ek Gelir", "Diğer"
    ]
    
    private var previewAmount: String {
        guard let amountDouble = Double(amount) else { return "" }
        let prefix = type == .expense ? "-" : "+"
        return "\(prefix)\(String(format: "%.2f ₺", abs(amountDouble)))"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Üst kısım - İşlem Türü Seçimi
                VStack(spacing: 16) {
                    Picker("", selection: $type) {
                        Text("Gider").tag(Transaction.TransactionType.expense)
                        Text("Gelir").tag(Transaction.TransactionType.income)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Tutar Girişi
                    HStack(alignment: .center) {
                        Text(type == .expense ? "-" : "+")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(type == .expense ? .theme.red : .theme.green)
                        
                        TextField("0", text: $amount)
                            .font(.system(size: 30, weight: .bold))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 150)
                        
                        Text("₺")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 20)
                }
                .padding()
                .background(Color(.systemBackground))
                
                // Form kısmı
                Form {
                    Section {
                        HStack {
                            Image(systemName: "text.alignleft")
                                .foregroundColor(.theme.accent)
                            TextField("Başlık", text: $title)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding(.vertical, 8)
                        
                        HStack {
                            Image(systemName: "folder.fill")
                                .foregroundColor(.theme.accent)
                            Picker("Kategori", selection: $category) {
                                ForEach(categories, id: \.self) { category in
                                    Text(category).tag(category)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                        
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.theme.accent)
                            DatePicker("Tarih", selection: $date, displayedComponents: [.date])
                        }
                        .padding(.vertical, 8)
                    }
                    
                    Section {
                        HStack {
                            Image(systemName: "note.text")
                                .foregroundColor(.theme.accent)
                            TextField("Not (İsteğe bağlı)", text: $note)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding(.vertical, 8)
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
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if let amountDouble = Double(amount), !title.isEmpty {
                            viewModel.addTransaction(
                                amount: amountDouble,
                                title: title,
                                type: type,
                                category: category
                            )
                            dismiss()
                        }
                    } label: {
                        Text("Kaydet")
                            .bold()
                            .foregroundColor((!amount.isEmpty && !title.isEmpty) ? .theme.accent : .gray)
                    }
                    .disabled(amount.isEmpty || title.isEmpty)
                }
            }
        }
    }
} 