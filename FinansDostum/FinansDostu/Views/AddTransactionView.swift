import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: MainViewModel
    
    @State private var title = ""
    @State private var amount = ""
    @State private var type: Transaction.TransactionType = .income
    @State private var category = "Diğer"
    @State private var note = ""
    @State private var date = Date()
    @State private var showingCategories = false
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case title, note
    }
    
    private let categories = [
        // Gider Kategorileri
        "Market ve Gıda",
        "Faturalar",
        "Kira",
        "Ulaşım",
        "Sağlık",
        "Eğitim",
        "Eğlence",
        "Alışveriş",
        "Giyim",
        "Elektronik",
        "Spor",
        "Bakım ve Kozmetik",
        "Ev Eşyaları",
        "Hobi",
        "Hediyeler",
        "Tatil",
        "Sigorta",
        "Kredi Ödemeleri",
        // Gelir Kategorileri
        "Maaş",
        "Ek Gelir",
        "Yatırım Geliri",
        "Kira Geliri",
        "Freelance",
        "Prim",
        "İkramiye",
        "Borç Tahsilatı",
        "Diğer"
    ]
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color.black : Color.white
    }
    
    private var cardBackgroundColor: Color {
        colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground)
    }
    
    private var typeColor: Color {
        if type == .income {
            return colorScheme == .dark ? Color.green.opacity(0.3) : Color.green.opacity(0.15)
        } else {
            return colorScheme == .dark ? Color.red.opacity(0.3) : Color.red.opacity(0.15)
        }
    }
    
    private var amountColor: Color {
        type == .income ? .green : .red
    }
    
    private var isValidAmount: Bool {
        guard let amount = Double(amount) else { return false }
        return amount > 0 && !amount.isNaN && amount.isFinite
    }
    
    private var canSave: Bool {
        !title.isEmpty && isValidAmount
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        VStack(spacing: 24) {
                            // Gelir/Gider Seçici
                            HStack(spacing: 12) {
                                // Gelir Butonu
                                Button {
                                    withAnimation { type = .income }
                                } label: {
                                    HStack {
                                        Image(systemName: "arrow.up.circle.fill")
                                        Text("Gelir")
                                    }
                                    .font(.headline)
                                    .foregroundColor(type == .income ? .green : .gray)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(type == .income ? Color.green.opacity(0.15) : Color(.systemGray5))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                
                                // Gider Butonu
                                Button {
                                    withAnimation { type = .expense }
                                } label: {
                                    HStack {
                                        Image(systemName: "arrow.down.circle.fill")
                                        Text("Gider")
                                    }
                                    .font(.headline)
                                    .foregroundColor(type == .expense ? .red : .gray)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(type == .expense ? Color.red.opacity(0.15) : Color(.systemGray5))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            .padding(.top)
                            
                            // Tutar Girişi
                            VStack(spacing: 8) {
                                Text(amount.isEmpty ? "0.00 ₺" : "\(amount) ₺")
                                    .font(.system(size: 44, weight: .medium, design: .rounded))
                                    .foregroundStyle(amountColor)
                                    .frame(height: 60)
                                
                                // Numerik Klavye
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                                    ForEach(1...9, id: \.self) { number in
                                        NumberButton(number: "\(number)", action: { appendNumber("\(number)") })
                                    }
                                    NumberButton(number: ".", action: { appendNumber(".") })
                                    NumberButton(number: "0", action: { appendNumber("0") })
                                    NumberButton(number: "⌫", action: deleteLastNumber)
                                }
                            }
                            .padding()
                            .background(cardBackgroundColor)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.05), radius: 10)
                            
                            // İşlem Detayları
                            VStack(spacing: 16) {
                                // Başlık
                                HStack {
                                    Image(systemName: "text.alignleft")
                                        .font(.title2)
                                        .foregroundStyle(.blue)
                                    TextField("Başlık", text: $title)
                                        .textInputAutocapitalization(.sentences)
                                        .focused($focusedField, equals: .title)
                                }
                                .padding()
                                .background(cardBackgroundColor)
                                .cornerRadius(12)
                                .id("title-field")
                                
                                // Kategori
                                Button {
                                    hideKeyboard()
                                    showingCategories = true
                                } label: {
                                    HStack {
                                        Image(systemName: "tag.fill")
                                            .font(.title2)
                                            .foregroundStyle(.blue)
                                        Text(category)
                                            .foregroundStyle(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(.gray)
                                    }
                                    .padding()
                                    .background(cardBackgroundColor)
                                    .cornerRadius(12)
                                }
                                
                                // Tarih
                                HStack {
                                    Image(systemName: "calendar")
                                        .font(.title2)
                                        .foregroundStyle(.blue)
                                    DatePicker("", selection: $date, displayedComponents: [.date])
                                        .labelsHidden()
                                }
                                .padding()
                                .background(cardBackgroundColor)
                                .cornerRadius(12)
                                
                                // Not
                                HStack {
                                    Image(systemName: "note.text")
                                        .font(.title2)
                                        .foregroundStyle(.blue)
                                    TextField("Not (İsteğe bağlı)", text: $note)
                                        .textInputAutocapitalization(.sentences)
                                        .focused($focusedField, equals: .note)
                                }
                                .padding()
                                .background(cardBackgroundColor)
                                .cornerRadius(12)
                                .id("note-field")
                            }
                            .id("details-section")
                        }
                        .padding()
                        .padding(.bottom, keyboardHeight > 0 ? keyboardHeight - 35 : 0) // Ekstra boşluk ekle
                    }
                    .onChange(of: focusedField) { newValue in
                        if newValue != nil {
                            withAnimation {
                                scrollProxy.scrollTo("details-section", anchor: .top)
                            }
                        }
                    }
                }
                .onAppear {
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                            keyboardHeight = keyboardFrame.height
                        }
                    }
                    
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                        keyboardHeight = 0
                    }
                }
            }
            .navigationTitle(type == .income ? "Gelir Ekle" : "Gider Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        saveTransaction()
                    }
                    .disabled(!canSave)
                }
                
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Tamam") {
                            hideKeyboard()
                        }
                    }
                }
            }
            .sheet(isPresented: $showingCategories) {
                CategoryPickerView(selectedCategory: $category)
            }
        }
    }
    
    private func hideKeyboard() {
        focusedField = nil
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func appendNumber(_ number: String) {
        // Nokta zaten varsa yeni nokta eklemeyi engelle
        if number == "." && amount.contains(".") { return }
        
        // Eğer nokta eklenecekse ve amount boşsa, önce 0 ekle
        if number == "." && amount.isEmpty {
            amount = "0."
            return
        }
        
        // Ondalık kısım kontrolü
        if amount.contains(".") {
            let parts = amount.split(separator: ".")
            // Split işleminden sonra en az 2 parça varsa ve ikinci parçanın uzunluğu 2'ye eşit veya büyükse
            if parts.count > 1 && parts[1].count >= 2 {
                return // Ondalık kısım zaten 2 basamağa ulaştı, daha fazla eklemeyi reddet
            }
        }
        
        // Diğer tüm durumlarda sayıyı ekle
        amount += number
    }
    
    private func deleteLastNumber() {
        if !amount.isEmpty {
            amount.removeLast()
        }
    }
    
    private func saveTransaction() {
        guard let amountDouble = Double(amount), isValidAmount else { return }
        
        viewModel.addTransaction(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            amount: amountDouble,
            type: type,
            category: category,
            date: date,
            note: note.isEmpty ? nil : note.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        dismiss()
    }
}

struct NumberButton: View {
    let number: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(number)
                .font(.title2.weight(.medium))
                .foregroundStyle(.primary)
                .frame(height: 60)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
    }
}

struct CategoryPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCategory: String
    @Environment(\.colorScheme) private var colorScheme
    
    let categories = [
        // Gider Kategorileri
        "Market ve Gıda",
        "Faturalar",
        "Kira",
        "Ulaşım",
        "Sağlık",
        "Eğitim",
        "Eğlence",
        "Alışveriş",
        "Giyim",
        "Elektronik",
        "Spor",
        "Bakım ve Kozmetik",
        "Ev Eşyaları",
        "Hobi",
        "Hediyeler",
        "Tatil",
        "Sigorta",
        "Kredi Ödemeleri",
        // Gelir Kategorileri
        "Maaş",
        "Ek Gelir",
        "Yatırım Geliri",
        "Kira Geliri",
        "Freelance",
        "Prim",
        "İkramiye",
        "Borç Tahsilatı",
        "Diğer"
    ]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Gider Kategorileri")) {
                    ForEach(categories.prefix(18), id: \.self) { category in
                        categoryRow(category)
                    }
                }
                
                Section(header: Text("Gelir Kategorileri")) {
                    ForEach(categories.suffix(9), id: \.self) { category in
                        categoryRow(category)
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
    
    private func categoryRow(_ category: String) -> some View {
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
