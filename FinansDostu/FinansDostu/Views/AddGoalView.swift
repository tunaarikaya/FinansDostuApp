import SwiftUI

struct AddGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MainViewModel
    
    @State private var title = ""
    @State private var targetAmount = ""
    @State private var initialSavedAmount = ""
    @State private var dueDate = Date()
    @State private var category: GoalCategory = .diger
    @State private var monthlyContribution = ""
    @State private var note = ""
    
    private var formattedTargetAmount: String {
        guard let amount = Double(targetAmount) else { return "0" }
        return String(format: "%.2f ₺", amount)
    }
    
    private var monthsUntilDueDate: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: Date(), to: dueDate)
        return components.month ?? 0
    }
    
    private var suggestedMonthlyContribution: Double {
        guard let target = Double(targetAmount),
              let initial = Double(initialSavedAmount) else { return 0 }
        let remaining = target - initial
        return remaining / Double(max(1, monthsUntilDueDate))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Hedef Detayları")) {
                    TextField("Hedef Başlığı", text: $title)
                        .autocapitalization(.sentences)
                    
                    Picker("Kategori", selection: $category) {
                        ForEach(GoalCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
                
                Section(header: Text("Finansal Detaylar")) {
                    HStack {
                        TextField("Hedef Tutar", text: $targetAmount)
                            .keyboardType(.decimalPad)
                        Text("₺")
                    }
                    
                    HStack {
                        TextField("Mevcut Birikim", text: $initialSavedAmount)
                            .keyboardType(.decimalPad)
                        Text("₺")
                    }
                    
                    DatePicker("Hedef Tarihi", selection: $dueDate, displayedComponents: [.date])
                }
                
                if let target = Double(targetAmount), let initial = Double(initialSavedAmount), target > 0 {
                    Section(header: Text("Hedef Özeti")) {
                        HStack {
                            Text("Kalan Tutar")
                            Spacer()
                            Text(String(format: "%.2f ₺", target - initial))
                                .foregroundColor(.red)
                        }
                        
                        HStack {
                            Text("Kalan Süre")
                            Spacer()
                            Text("\(monthsUntilDueDate) ay")
                        }
                        
                        HStack {
                            Text("Önerilen Aylık Birikim")
                            Spacer()
                            Text(String(format: "%.2f ₺", suggestedMonthlyContribution))
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Section(header: Text("Ek Bilgiler")) {
                    TextField("Not (İsteğe bağlı)", text: $note)
                }
            }
            .navigationTitle("Yeni Hedef")
            .navigationBarItems(
                leading: Button("İptal") { dismiss() },
                trailing: Button("Kaydet") {
                    if let targetAmountDouble = Double(targetAmount),
                       let savedAmountDouble = Double(initialSavedAmount),
                       !title.isEmpty {
                        viewModel.addGoal(
                            title: title,
                            targetAmount: targetAmountDouble,
                            savedAmount: savedAmountDouble,
                            dueDate: dueDate,
                            category: category,
                            note: note.isEmpty ? nil : note
                        )
                        dismiss()
                    }
                }
                .disabled(title.isEmpty || targetAmount.isEmpty || initialSavedAmount.isEmpty)
            )
        }
    }
} 