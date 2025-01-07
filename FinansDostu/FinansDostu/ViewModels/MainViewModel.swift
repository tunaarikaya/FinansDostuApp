import Foundation
import CoreData
import SwiftUI

class MainViewModel: ObservableObject {
    @Published var user: User
    @Published var transactions: [Transaction] = []
    @Published var searchText: String = ""
    @Published var filteredTransactions: [Transaction] = []
    @Published var plannedPayments: [PlannedPayment] = []
    @Published var goals: [Goal] = []
    
    private var persistenceController: PersistenceController
    
    @AppStorage("isDarkMode") var isDarkMode: Bool = false {
        didSet {
            user.prefersDarkMode = isDarkMode
            setAppearance(isDarkMode)
        }
    }
    
    init(persistenceController: PersistenceController = PersistenceController.shared) {
        self.persistenceController = persistenceController
        self.user = User(id: UUID(), name: "Tuna Arıkaya", balance: 0)
        fetchTransactions()
        
        // Test verileri ekleyelim (sadece test için)
        if transactions.isEmpty {
            // Maaş ve düzenli gelirler
            addTransaction(amount: 15000, title: "Maaş", type: .income, category: "Maaş")
            addTransaction(amount: 2000, title: "Ek İş", type: .income, category: "Ek Gelir")
            
            // Market harcamaları
            addTransaction(amount: 750, title: "Haftalık Market", type: .expense, category: "Market")
            addTransaction(amount: 250, title: "Mini Market", type: .expense, category: "Market")
            
            // Faturalar
            addTransaction(amount: 400, title: "Elektrik", type: .expense, category: "Faturalar")
            addTransaction(amount: 200, title: "Su", type: .expense, category: "Faturalar")
            addTransaction(amount: 180, title: "İnternet", type: .expense, category: "Faturalar")
            
            // Ulaşım
            addTransaction(amount: 300, title: "Akbil", type: .expense, category: "Ulaşım")
            addTransaction(amount: 500, title: "Benzin", type: .expense, category: "Ulaşım")
            
            // Eğlence
            addTransaction(amount: 150, title: "Netflix", type: .expense, category: "Eğlence")
            addTransaction(amount: 200, title: "Sinema", type: .expense, category: "Eğlence")
            
            // Alışveriş
            addTransaction(amount: 800, title: "Kıyafet", type: .expense, category: "Alışveriş")
            
            // Farklı tarihlerde işlemler için
            let calendar = Calendar.current
            
            // Geçmiş tarihli işlemler
            if let date1 = calendar.date(byAdding: .day, value: -15, to: Date()),
               let date2 = calendar.date(byAdding: .day, value: -10, to: Date()),
               let date3 = calendar.date(byAdding: .day, value: -5, to: Date()) {
                
                let context = persistenceController.container.viewContext
                
                // 15 gün önce
                let transaction1 = TransactionEntity(context: context)
                transaction1.id = UUID()
                transaction1.amount = 600
                transaction1.title = "Market Alışverişi"
                transaction1.type = Transaction.TransactionType.expense.rawValue
                transaction1.category = "Market"
                transaction1.date = date1
                
                // 10 gün önce
                let transaction2 = TransactionEntity(context: context)
                transaction2.id = UUID()
                transaction2.amount = 15000
                transaction2.title = "Geçen Ay Maaş"
                transaction2.type = Transaction.TransactionType.income.rawValue
                transaction2.category = "Maaş"
                transaction2.date = date2
                
                // 5 gün önce
                let transaction3 = TransactionEntity(context: context)
                transaction3.id = UUID()
                transaction3.amount = 450
                transaction3.title = "Giyim Alışverişi"
                transaction3.type = Transaction.TransactionType.expense.rawValue
                transaction3.category = "Alışveriş"
                transaction3.date = date3
                
                try? context.save()
            }
            
            fetchTransactions()
        }
    }
    
    func filterTransactions() {
        if searchText.isEmpty {
            filteredTransactions = transactions
        } else {
            filteredTransactions = transactions.filter { transaction in
                transaction.title.localizedCaseInsensitiveContains(searchText) ||
                String(format: "%.2f", transaction.amount).contains(searchText)
            }
        }
    }
    
    func fetchTransactions() {
        let request = NSFetchRequest<TransactionEntity>(entityName: "TransactionEntity")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TransactionEntity.date, ascending: false)]
        
        do {
            let results = try persistenceController.container.viewContext.fetch(request)
            transactions = results.map { entity in
                Transaction(
                    id: entity.id ?? UUID(),
                    amount: entity.amount,
                    title: entity.title ?? "",
                    type: entity.type == "income" ? .income : .expense,
                    date: entity.date ?? Date(),
                    category: entity.category ?? "Diğer"
                )
            }
            
            // Debug için işlemleri yazdıralım
            print("Transactions:")
            transactions.forEach { transaction in
                print("- \(transaction.title): \(transaction.amount) (\(transaction.type))")
            }
            
            filteredTransactions = transactions
            updateBalance()
        } catch {
            print("Error fetching transactions: \(error)")
        }
    }
    
    func addTransaction(amount: Double, title: String, type: Transaction.TransactionType, category: String = "Diğer") {
        let viewContext = persistenceController.container.viewContext
        let newTransaction = TransactionEntity(context: viewContext)
        newTransaction.id = UUID()
        newTransaction.amount = amount
        newTransaction.title = title
        newTransaction.type = type.rawValue
        newTransaction.date = Date()
        newTransaction.category = category
        
        do {
            try viewContext.save()
            print("Transaction saved successfully") // Debug için
            fetchTransactions()
        } catch {
            print("Error saving transaction: \(error)")
        }
    }
    
    private func updateBalance() {
        let balance = transactions.reduce(0) { result, transaction in
            switch transaction.type {
            case .income:
                return result + transaction.amount
            case .expense:
                return result - transaction.amount
            }
        }
        user.balance = balance
    }
    
    var totalIncome: Double {
        transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }
    
    var totalExpense: Double {
        transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }
    
    var categoryExpenses: [CategoryExpense] {
        // Kategori bazlı harcamaları hesapla
        Dictionary(grouping: transactions.filter { $0.type == .expense }) { $0.category }
            .map { CategoryExpense(name: $0.key, amount: $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.amount > $1.amount }
    }
    
    var monthlyData: [MonthlyData] {
        // Aylık trend verilerini hesapla
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: transactions) {
            calendar.startOfDay(for: $0.date)
        }
        
        return grouped.map { date, transactions in
            MonthlyData(
                date: date,
                amount: transactions.reduce(0) { $0 + ($1.type == .income ? $1.amount : -$1.amount) },
                isExpense: transactions.first?.type == .expense
            )
        }.sorted { $0.date < $1.date }
    }
    
    var highestExpense: (title: String, amount: Double) {
        if let highest = transactions.filter({ $0.type == .expense }).max(by: { $0.amount < $1.amount }) {
            return (highest.title, highest.amount)
        }
        return ("", 0)
    }
    
    var averageExpense: Double {
        let expenses = transactions.filter { $0.type == .expense }
        guard !expenses.isEmpty else { return 0 }
        return expenses.reduce(0) { $0 + $1.amount } / Double(expenses.count)
    }
    
    func addPlannedPayment(title: String, amount: Double, dueDate: Date, note: String? = nil, isRecurring: Bool = false, recurringInterval: AddPlannedPaymentView.RecurringInterval? = nil) {
        let newPayment = PlannedPayment(
            id: UUID(),
            title: title,
            amount: amount,
            dueDate: dueDate,
            note: note,
            isRecurring: isRecurring,
            recurringInterval: recurringInterval?.rawValue
        )
        plannedPayments.append(newPayment)
        // Burada CoreData'ya kaydetme işlemi de eklenebilir
    }
    
    var totalGoalAmount: Double {
        goals.reduce(0) { $0 + $1.targetAmount }
    }
    
    var totalSavedAmount: Double {
        goals.reduce(0) { $0 + $1.savedAmount }
    }
    
    var totalProgress: Double {
        totalGoalAmount > 0 ? totalSavedAmount / totalGoalAmount : 0
    }
    
    func addGoal(title: String, targetAmount: Double, savedAmount: Double, dueDate: Date, category: GoalCategory = .diger, note: String? = nil) {
        let context = persistenceController.container.viewContext
        let newGoal = GoalEntity(context: context)
        
        newGoal.id = UUID()
        newGoal.title = title
        newGoal.targetAmount = targetAmount
        newGoal.savedAmount = savedAmount
        newGoal.dueDate = dueDate
        newGoal.note = note
        newGoal.category = category.rawValue
        newGoal.monthlyContributions = encodeContributions([])
        newGoal.lastUpdateDate = Date()
        
        do {
            try context.save()
            fetchGoals()
        } catch {
            print("Error saving goal: \(error)")
        }
    }
    
    func addContribution(to goal: Goal, amount: Double) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            var updatedGoal = goal
            updatedGoal.savedAmount += amount
            updatedGoal.monthlyContributions.append(amount)
            updatedGoal.lastUpdateDate = Date()
            goals[index] = updatedGoal
        }
    }
    
    func deleteGoal(_ goal: Goal) {
        goals.removeAll { $0.id == goal.id }
    }
    
    func updateGoal(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
        }
    }
    
    func getSavingSuggestion(for goal: Goal) -> String? {
        let monthlyNeeded = goal.requiredMonthlyContribution
        let averageExpense = self.averageExpense
        
        if monthlyNeeded > averageExpense * 0.5 {
            return "Hedefinize ulaşmak için aylık harcamalarınızı gözden geçirmenizi öneririz. Özellikle \(highestExpense.title) kategorisinde tasarruf yapabilirsiniz."
        } else if !goal.isOnTrack {
            return "Hedefinize zamanında ulaşmak için aylık \(String(format: "%.2f", monthlyNeeded)) ₺ biriktirmeniz gerekiyor. Düzenli katkı yapmayı unutmayın."
        }
        return nil
    }
    
    func updateUserProfile(name: String, email: String?, profileImageData: Data?) {
        user.name = name
        user.email = email
        user.profileImageData = profileImageData
        // Burada CoreData'ya kaydetme işlemi eklenebilir
    }
    
    func toggleDarkMode() {
        isDarkMode.toggle()
    }
    
    func toggleNotifications(_ enabled: Bool) {
        user.notificationsEnabled = enabled
        // Burada bildirim izinlerini yönetme kodu eklenebilir
    }
    
    private func setAppearance(_ isDark: Bool) {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window?.overrideUserInterfaceStyle = isDark ? .dark : .light
    }
    
    // MARK: - Goals Management
    func fetchGoals() {
        let request = NSFetchRequest<GoalEntity>(entityName: "GoalEntity")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \GoalEntity.dueDate, ascending: true)]
        
        do {
            let results = try persistenceController.container.viewContext.fetch(request)
            goals = results.map { entity in
                Goal(
                    id: entity.id ?? UUID(),
                    title: entity.title ?? "",
                    targetAmount: entity.targetAmount,
                    savedAmount: entity.savedAmount,
                    dueDate: entity.dueDate ?? Date(),
                    note: entity.note,
                    category: GoalCategory(rawValue: entity.category ?? "") ?? .diger,
                    monthlyContributions: decodeContributions(from: entity.monthlyContributions),
                    lastUpdateDate: entity.lastUpdateDate ?? Date()
                )
            }
        } catch {
            print("Error fetching goals: \(error)")
        }
    }
    
    // MARK: - Planned Payments Management
    func fetchPlannedPayments() {
        let request = NSFetchRequest<PlannedPaymentEntity>(entityName: "PlannedPaymentEntity")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PlannedPaymentEntity.dueDate, ascending: true)]
        
        do {
            let results = try persistenceController.container.viewContext.fetch(request)
            plannedPayments = results.map { entity in
                PlannedPayment(
                    id: entity.id ?? UUID(),
                    title: entity.title ?? "",
                    amount: entity.amount,
                    dueDate: entity.dueDate ?? Date(),
                    note: entity.note,
                    isRecurring: entity.isRecurring,
                    recurringInterval: entity.recurringInterval
                )
            }
        } catch {
            print("Error fetching planned payments: \(error)")
        }
    }
    
    func addPlannedPayment(title: String, amount: Double, dueDate: Date, note: String? = nil, isRecurring: Bool = false, recurringInterval: String? = nil) {
        let context = persistenceController.container.viewContext
        let newPayment = PlannedPaymentEntity(context: context)
        
        newPayment.id = UUID()
        newPayment.title = title
        newPayment.amount = amount
        newPayment.dueDate = dueDate
        newPayment.note = note
        newPayment.isRecurring = isRecurring
        newPayment.recurringInterval = recurringInterval
        
        do {
            try context.save()
            fetchPlannedPayments()
        } catch {
            print("Error saving planned payment: \(error)")
        }
    }
    
    // MARK: - Helper Functions
    private func encodeContributions(_ contributions: [Double]) -> Data? {
        try? JSONEncoder().encode(contributions)
    }
    
    private func decodeContributions(from data: Data?) -> [Double] {
        guard let data = data else { return [] }
        return (try? JSONDecoder().decode([Double].self, from: data)) ?? []
    }
}

// Yardımcı modeller
struct CategoryExpense: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
}

struct MonthlyData: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
    let isExpense: Bool
} 
