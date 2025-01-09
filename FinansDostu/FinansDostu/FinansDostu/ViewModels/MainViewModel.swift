import Foundation
import CoreData
import SwiftUI

class MainViewModel: ObservableObject {
    @Published var user: User
    @Published var transactions: [Transaction] = [] {
        didSet {
            updateBalance()
        }
    }
    @Published var searchText: String = ""
    @Published var filteredTransactions: [Transaction] = []
    @Published var plannedPayments: [PlannedPayment] = []
    @Published var categoryInsights: [BudgetInsight] = []
    @Published var suggestedBudgets: [CategoryBudget] = []
    @Published var currentSavingTip: String?
    @Published var categoryExpenses: [CategoryExpense] = []
    
    private var persistenceController: PersistenceController
    private let spendingPredictor = SpendingPredictor()
    
    @AppStorage("isDarkMode") var isDarkMode: Bool = true {
        didSet {
            user.prefersDarkMode = isDarkMode
            setAppearance(isDarkMode)
        }
    }
    
    init(persistenceController: PersistenceController = PersistenceController.shared) {
        self.persistenceController = persistenceController
        self.user = User(id: UUID(), name: "Tuna Arıkaya", balance: 0)
        
        fetchTransactions()
        fetchPlannedPayments()
        updateBudgetInsights()
        updateSavingTip()
        updateBalance()
    }
    
    private func updateBalance() {
        let totalIncome = transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        let totalExpense = transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        user.balance = totalIncome - totalExpense
    }
    
    func fetchTransactions() {
        let request = NSFetchRequest<TransactionEntity>(entityName: "TransactionEntity")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TransactionEntity.date, ascending: false)]
        
        do {
            let results = try persistenceController.container.viewContext.fetch(request)
            transactions = results.map { Transaction(from: $0) }
            filterTransactions()
            calculateCategoryExpenses()
        } catch {
            print("Error fetching transactions: \(error)")
        }
    }
    
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
                    recurringInterval: entity.recurringInterval,
                    isPaid: entity.isPaid
                )
            }
        } catch {
            print("Error fetching planned payments: \(error)")
        }
    }
    
    func filterTransactions() {
        if searchText.isEmpty {
            filteredTransactions = transactions
        } else {
            filteredTransactions = transactions.filter { transaction in
                transaction.title.localizedCaseInsensitiveContains(searchText) ||
                transaction.category.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    func updateBudgetInsights() {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        
        let expensesByCategory = Dictionary(grouping: transactions.filter { $0.type == .expense }) { $0.category }
        
        let insights = expensesByCategory.map { category, categoryTransactions -> BudgetInsight in
            let currentMonthTransactions = categoryTransactions.filter {
                calendar.component(.month, from: $0.date) == currentMonth
            }
            
            let previousMonthTransactions = categoryTransactions.filter {
                calendar.component(.month, from: $0.date) == (currentMonth > 1 ? currentMonth - 1 : 12)
            }
            
            let currentSpending = currentMonthTransactions.reduce(0) { $0 + $1.amount }
            let previousSpending = previousMonthTransactions.reduce(0) { $0 + $1.amount }
            
            let trend: BudgetInsight.Trend = {
                if currentSpending > previousSpending {
                    return .increased
                } else if currentSpending < previousSpending {
                    return .decreased
                } else {
                    return .stable
                }
            }()
            
            let message = {
                switch trend {
                case .increased:
                    return "Bu ay geçen aya göre daha fazla harcama yaptınız."
                case .decreased:
                    return "Bu ay geçen aya göre tasarruf ettiniz."
                case .stable:
                    return "Harcamalarınız geçen ayla benzer seviyede."
                }
            }()
            
            let suggestion = previousSpending * 0.9
            
            return BudgetInsight(
                id: UUID(),
                category: category,
                currentSpending: currentSpending,
                trend: trend,
                message: message,
                suggestion: suggestion
            )
        }
        
        self.categoryInsights = insights
        updateSuggestedBudgets()
    }
    
    private func updateSuggestedBudgets() {
        suggestedBudgets = categoryInsights.map { insight in
            CategoryBudget(
                id: UUID(),
                category: insight.category,
                suggestedAmount: insight.suggestion,
                currentAmount: insight.currentSpending,
                progress: insight.suggestion > 0 ? insight.currentSpending / insight.suggestion : 1.0
            )
        }
    }
    
    private func updateSavingTip() {
        let tips = [
            "Düzenli olarak harcamalarınızı takip edin ve gereksiz harcamalardan kaçının.",
            "Alışveriş yapmadan önce liste hazırlayın ve listede olmayan ürünleri almayın.",
            "Faturalarınızı otomatik ödemeye alarak gecikme cezalarından kaçının.",
            "Toplu taşıma kullanarak yakıt masraflarından tasarruf edin.",
            "Market alışverişlerinizi indirim günlerinde yapın."
        ]
        
        currentSavingTip = tips.randomElement()
    }
    
    private func setAppearance(_ isDark: Bool) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = isDark ? .dark : .light
            }
        }
    }
    
    // Toplam gelir ve gider hesaplamaları
    var totalIncome: Double {
        transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }
    
    var totalExpense: Double {
        transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }
    
    var highestExpense: Transaction {
        transactions.filter { $0.type == .expense }
            .max(by: { $0.amount < $1.amount }) ?? 
            Transaction(amount: 0, title: "Henüz işlem yok", type: .expense)
    }
    
    var averageExpense: Double {
        let expenses = transactions.filter { $0.type == .expense }
        return expenses.isEmpty ? 0 : expenses.reduce(0) { $0 + $1.amount } / Double(expenses.count)
    }
    
    // Planlı ödemeler için fonksiyonlar
    func deletePlannedPayment(_ payment: PlannedPayment) {
        let context = persistenceController.container.viewContext
        let request = NSFetchRequest<PlannedPaymentEntity>(entityName: "PlannedPaymentEntity")
        request.predicate = NSPredicate(format: "id == %@", payment.id as CVarArg)
        
        do {
            if let entity = try context.fetch(request).first {
                context.delete(entity)
                try context.save()
                fetchPlannedPayments()
            }
        } catch {
            print("Error deleting planned payment: \(error)")
        }
    }
    
    func updatePlannedPayment(_ payment: PlannedPayment) {
        let context = persistenceController.container.viewContext
        let request = NSFetchRequest<PlannedPaymentEntity>(entityName: "PlannedPaymentEntity")
        request.predicate = NSPredicate(format: "id == %@", payment.id as CVarArg)
        
        do {
            if let entity = try context.fetch(request).first {
                entity.title = payment.title
                entity.amount = payment.amount
                entity.dueDate = payment.dueDate
                entity.note = payment.note
                entity.isRecurring = payment.isRecurring
                entity.recurringInterval = payment.recurringInterval
                entity.isPaid = payment.isPaid
                
                try context.save()
                fetchPlannedPayments()
            }
        } catch {
            print("Error updating planned payment: \(error)")
        }
    }
    
    func addTransaction(title: String, amount: Double, type: Transaction.TransactionType, category: String, date: Date, note: String? = nil) {
        let context = persistenceController.container.viewContext
        let entity = TransactionEntity(context: context)
        
        entity.id = UUID()
        entity.title = title
        entity.amount = amount
        entity.type = type.rawValue
        entity.category = category
        entity.date = date
       // entity.note = note
        
        do {
            try context.save()
            fetchTransactions()
            updateBudgetInsights()
            updateSavingTip()
        } catch {
            print("Error saving transaction: \(error)")
        }
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        let context = persistenceController.container.viewContext
        let request = NSFetchRequest<TransactionEntity>(entityName: "TransactionEntity")
        request.predicate = NSPredicate(format: "id == %@", transaction.id as CVarArg)
        
        do {
            if let entity = try context.fetch(request).first {
                context.delete(entity)
                try context.save()
                fetchTransactions()
                updateBudgetInsights()
                updateSavingTip()
            }
        } catch {
            print("Error deleting transaction: \(error)")
        }
    }
    
    func updateTransaction(_ transaction: Transaction) {
        let context = persistenceController.container.viewContext
        let request = NSFetchRequest<TransactionEntity>(entityName: "TransactionEntity")
        request.predicate = NSPredicate(format: "id == %@", transaction.id as CVarArg)
        
        do {
            if let entity = try context.fetch(request).first {
                entity.title = transaction.title
                entity.amount = transaction.amount
                entity.type = transaction.type.rawValue
                entity.category = transaction.category
                entity.date = transaction.date
                
                try context.save()
                fetchTransactions()
                updateBudgetInsights()
                updateSavingTip()
            }
        } catch {
            print("Error updating transaction: \(error)")
        }
    }
    
    func addPlannedPayment(title: String, amount: Double, dueDate: Date, note: String? = nil, isRecurring: Bool = false, recurringInterval: String? = nil) {
        let context = persistenceController.container.viewContext
        let entity = PlannedPaymentEntity(context: context)
        
        entity.id = UUID()
        entity.title = title
        entity.amount = amount
        entity.dueDate = dueDate
        entity.note = note
        entity.isRecurring = isRecurring
        entity.recurringInterval = recurringInterval
        entity.isPaid = false
        
        do {
            try context.save()
            fetchPlannedPayments()
        } catch {
            print("Error saving planned payment: \(error)")
        }
    }
    
    func updateUserProfile(name: String, email: String?, notificationsEnabled: Bool) {
        // User modelini güncelle
        user.name = name
        user.email = email
        user.notificationsEnabled = notificationsEnabled
        
        // CoreData'ya kaydetme işlemi
        let context = persistenceController.container.viewContext
        
        // UserEntity'yi kaydet
        do {
            // Mevcut kullanıcıyı bul veya yeni oluştur
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserEntity")
            let results = try context.fetch(fetchRequest)
            let userEntity = results.first ?? NSEntityDescription.insertNewObject(forEntityName: "UserEntity", into: context)
            
            // Değerleri güncelle
            userEntity.setValue(user.id, forKey: "id")
            userEntity.setValue(name, forKey: "name")
            userEntity.setValue(email, forKey: "email")
            userEntity.setValue(notificationsEnabled, forKey: "notificationsEnabled")
            userEntity.setValue(isDarkMode, forKey: "prefersDarkMode")
            
            try context.save()
        } catch {
            print("Error saving user profile: \(error)")
        }
    }
    
    private func calculateCategoryExpenses() {
        let groupedTransactions = Dictionary(grouping: transactions) { $0.category }
        let totalExpense = transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        
        categoryExpenses = groupedTransactions.compactMap { category, transactions in
            let categoryTotal = transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
            let percentage = totalExpense > 0 ? (categoryTotal / totalExpense) * 100 : 0
            return CategoryExpense(category: category, amount: categoryTotal, percentage: percentage)
        }
        .sorted { $0.amount > $1.amount }
    }
} 
