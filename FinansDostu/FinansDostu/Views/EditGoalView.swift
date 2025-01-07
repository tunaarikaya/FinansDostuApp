import SwiftUI

struct EditGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MainViewModel
    
    let goal: Goal
    
    @State private var title: String
    @State private var targetAmount: String
    @State private var savedAmount: String
    @State private var dueDate: Date
    @State private var note: String
    @State private var category: GoalCategory
    
    init(viewModel: MainViewModel, goal: Goal) {
        self.viewModel = viewModel
        self.goal = goal
        
        // State değişkenlerini mevcut hedef değerleriyle başlat
        _title = State(initialValue: goal.title)
        _targetAmount = State(initialValue: String(format: "%.2f", goal.targetAmount))
        _savedAmount = State(initialValue: String(format: "%.2f", goal.savedAmount))
        _dueDate = State(initialValue: goal.dueDate)
        _note = State(initialValue: goal.note ?? "")
        _category = State(initialValue: goal.category)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Hedef Detayları")) {
                    TextField("Hedef Başlığı", text: $title)
                    
                    TextField("Hedef Tutar", text: $targetAmount)
                        .keyboardType(.decimalPad)
                    
                    TextField("Biriken Tutar", text: $savedAmount)
                        .keyboardType(.decimalPad)
                    
                    DatePicker("Bitiş Tarihi", selection: $dueDate, displayedComponents: [.date])
                    
                    Picker("Kategori", selection: $category) {
                        ForEach(GoalCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    
                    TextField("Not (İsteğe bağlı)", text: $note)
                }
                
                Section {
                    Button(role: .destructive) {
                        viewModel.deleteGoal(goal)
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Hedefi Sil")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Hedefi Düzenle")
            .navigationBarItems(
                leading: Button("İptal") { dismiss() },
                trailing: Button("Kaydet") {
                    if let targetAmountDouble = Double(targetAmount),
                       let savedAmountDouble = Double(savedAmount),
                       !title.isEmpty {
                        
                        var updatedGoal = goal
                        updatedGoal.title = title
                        updatedGoal.targetAmount = targetAmountDouble
                        updatedGoal.savedAmount = savedAmountDouble
                        updatedGoal.dueDate = dueDate
                        updatedGoal.note = note.isEmpty ? nil : note
                        updatedGoal.category = category
                        
                        viewModel.updateGoal(updatedGoal)
                        dismiss()
                    }
                }
                .disabled(title.isEmpty || targetAmount.isEmpty || savedAmount.isEmpty)
            )
        }
    }
} 