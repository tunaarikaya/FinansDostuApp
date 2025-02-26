import Foundation
import CoreData
import SwiftUI
import UserNotifications

// Delegate protokolü tanımı
protocol MainViewModelDelegate: AnyObject {
    func didUpdateData()
}

public class MainViewModel: ObservableObject {
    @Published var user: User
    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var plannedPayments: [PlannedPayment] = []
    @Published var searchText: String = ""
    @Published var filteredTransactions: [Transaction] = []
    @Published var categoryInsights: [BudgetInsight] = []
    @Published var suggestedBudgets: [CategoryBudget] = []
    @Published var currentSavingTip: String?
    @Published var categoryExpenses: [CategoryExpense] = []
    @Published var overduePayments: [PlannedPayment] = []
    
    private let persistenceController: PersistenceController
    private let spendingPredictor = SpendingPredictor()
    private let recurringPaymentManager: RecurringPaymentManager
    
    @AppStorage("isDarkMode") var isDarkMode: Bool = true {
        didSet {
            user.prefersDarkMode = isDarkMode
            setAppearance(isDarkMode)
        }
    }
    
    weak var delegate: MainViewModelDelegate?
    
    init(persistenceController: PersistenceController = PersistenceController.shared) {
        self.persistenceController = persistenceController
        self.user = User(id: UUID(), name: "Kullanıcı adı", balance: 0)
        self.recurringPaymentManager = RecurringPaymentManager(persistenceController: persistenceController)
        
        loadUserProfile()
        loadInitialData()
        
        // Her uygulama açılışında tekrarlayan ödemeleri kontrol et
        do {
            try recurringPaymentManager.processRecurringPayments()
            checkOverduePayments() // Vadesi geçen ödemeleri kontrol et
        } catch {
            print("Tekrarlayan ödemeler işlenirken hata: \(error.localizedDescription)")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func loadInitialData() {
        let context = persistenceController.container.viewContext
        fetchTransactions(in: context)
        fetchPlannedPayments(in: context)
        updateBalance()
        updateBudgetInsights()
    }
    
    private func fetchTransactions(in context: NSManagedObjectContext) {
        let request = NSFetchRequest<TransactionEntity>(entityName: "TransactionEntity")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TransactionEntity.date, ascending: false)]
        request.fetchBatchSize = 20 // Batch size ekle
        
        do {
            let results = try context.fetch(request)
            DispatchQueue.main.async { [weak self] in
                self?.transactions = results.map { Transaction(from: $0) }
            }
        } catch {
            print("Error fetching transactions: \(error)")
        }
    }
    
    private func fetchPlannedPayments(in context: NSManagedObjectContext) {
        let request = NSFetchRequest<PlannedPaymentEntity>(entityName: "PlannedPaymentEntity")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PlannedPaymentEntity.dueDate, ascending: true)]
        request.fetchBatchSize = 20
        
        do {
            let results = try context.fetch(request)
            DispatchQueue.main.async { [weak self] in
                self?.plannedPayments = results.map { entity in
                    PlannedPayment(
                        id: entity.id ?? UUID(),
                        title: entity.title ?? "",
                        amount: entity.amount,
                        dueDate: entity.dueDate ?? Date(),
                        isPaid: entity.isPaid,
                        note: entity.note,
                        notificationPreferences: NotificationPreference(),
                        isRecurring: entity.isRecurring,
                        recurringInterval: entity.recurringInterval
                    )
                }
            }
        } catch {
            print("Error fetching planned payments: \(error)")
        }
    }
    
    private func updateBalance() {
        let context = persistenceController.container.viewContext
        let request = NSFetchRequest<TransactionEntity>(entityName: "TransactionEntity")
        
        do {
            let results = try context.fetch(request)
            let totalIncome = results
                .filter { $0.type == "income" }
                .reduce(0) { $0 + $1.amount }
            
            let totalExpense = results
                .filter { $0.type == "expense" }
                .reduce(0) { $0 + $1.amount }
            
            self.user.balance = totalIncome - totalExpense
            self.objectWillChange.send()
        } catch {
            print("Bakiye güncellenirken hata: \(error)")
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
        
        // Performans için lazy kullanımı
        let currentMonthTransactions = transactions.lazy.filter {
            calendar.component(.month, from: $0.date) == currentMonth && $0.type == .expense
        }
        
        let previousMonthTransactions = transactions.lazy.filter {
            let dateComponents = calendar.dateComponents([.month], from: $0.date)
            return dateComponents.month == (currentMonth > 1 ? currentMonth - 1 : 12) && $0.type == .expense
        }
        
        // Kategorilere göre gruplama optimizasyonu
        let groupedCurrent = Dictionary(grouping: currentMonthTransactions, by: { $0.category })
        let groupedPrevious = Dictionary(grouping: previousMonthTransactions, by: { $0.category })
        
        // Paralel hesaplama
        self.categoryInsights = groupedCurrent.concurrentMap { category, currentTransactions in
            let currentSpending = currentTransactions.reduce(0) { $0 + $1.amount }
            let previousSpending = groupedPrevious[category]?.reduce(0) { $0 + $1.amount } ?? 0
            
            let trend: BudgetInsight.Trend = {
                if currentSpending > previousSpending { return .increased }
                if currentSpending < previousSpending { return .decreased }
                return .stable
            }()
            
            return BudgetInsight(
                id: UUID(),
                category: category,
                currentSpending: currentSpending,
                previousSpending: previousSpending,
                trend: trend,
                message: self.generateMessage(for: trend),
                suggestion: self.calculateSuggestedLimit(
                    currentSpending: currentSpending,
                    previousSpending: previousSpending
                )
            )
        }
        
        self.updateSuggestedBudgets()
    }
    
    private func updateSuggestedBudgets() {
        suggestedBudgets = categoryInsights.map { insight in
            let progress = insight.suggestion > 0 ? min(max(0, insight.currentSpending / insight.suggestion), 1.0) : 0
            return CategoryBudget(
                id: UUID(),
                category: insight.category,
                suggestedAmount: insight.suggestion,
                currentAmount: insight.currentSpending,
                progress: progress
            )
        }
    }
    
    private func generateMessage(for trend: BudgetInsight.Trend) -> String {
        switch trend {
        case .increased:
            return "Bu ay geçen aya göre daha fazla harcama yaptınız."
        case .decreased:
            return "Bu ay geçen aya göre tasarruf ettiniz."
        case .stable:
            return "Harcamalarınız geçen ayla benzer seviyede."
        }
    }
    
    private func calculateSuggestedLimit(currentSpending: Double, previousSpending: Double) -> Double {
        let base = previousSpending > 0 ? previousSpending : currentSpending
        let suggested = base * 0.9
        return max(suggested, 0)
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
            let results = try context.fetch(request)
            if let entityToDelete = results.first {
                withAnimation {
                    context.delete(entityToDelete)
                    do {
                        try context.save()
                        fetchPlannedPayments(in: context) // Listeyi yeniden yükle
                    } catch {
                        print("Error saving context after deletion: \(error)")
                    }
                }
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
                fetchPlannedPayments(in: context)
            }
        } catch {
            print("Error updating planned payment: \(error)")
        }
    }
    
    func addTransaction(
        title: String,
        amount: Double,
        type: Transaction.TransactionType,
        category: String,
        date: Date,
        note: String? = nil
    ) {
        let context = persistenceController.container.viewContext
        let entity = TransactionEntity(context: context)
        
        entity.id = UUID()
        entity.title = title
        entity.amount = amount
        entity.type = type.rawValue
        entity.category = category
        entity.date = date
        entity.note = note
        
        do {
            try context.save()
            fetchTransactions(in: context)
            updateBalance()
            updateBudgetInsights()
        } catch {
            print("İşlem kaydedilirken hata: \(error)")
        }
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        let context = persistenceController.container.viewContext
        let request = NSFetchRequest<TransactionEntity>(entityName: "TransactionEntity")
        request.predicate = NSPredicate(format: "id == %@", transaction.id as CVarArg)
        
        do {
            if let entity = try context.fetch(request).first {
                // Bakiyeyi güncelle
                if transaction.type == .income {
                    user.balance -= transaction.amount
                } else {
                    user.balance += transaction.amount
                }
                
                // İşlemi sil
                context.delete(entity)
                try context.save()
                
                // UI'ı güncelle
                withAnimation {
                    fetchTransactions(in: context)
                    updateBudgetInsights()
                }
            }
        } catch {
            print("İşlem silinirken hata: \(error)")
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
                fetchTransactions(in: context)
                updateBudgetInsights()
            }
        } catch {
            print("Error updating transaction: \(error)")
        }
    }
    
    func addPlannedPayment(
        title: String,
        amount: Double,
        dueDate: Date,
        note: String? = nil,
        isRecurring: Bool = false,
        recurringInterval: String? = nil
    ) {
        let context = persistenceController.container.viewContext
        
        do {
            if isRecurring, let interval = recurringInterval {
                // Tekrarlayan ödeme oluştur
                try recurringPaymentManager.createRecurringPayment(
                    title: title,
                    amount: amount,
                    startDate: dueDate,
                    interval: interval,
                    note: note,
                    in: context
                )
            } else {
                // Tek seferlik ödeme oluştur
                let entity = PlannedPaymentEntity(context: context)
                entity.id = UUID()
                entity.title = title
                entity.amount = amount
                entity.dueDate = dueDate
                entity.note = note
                entity.isRecurring = false
                entity.isPaid = false
                
                try context.save()
            }
            
            fetchPlannedPayments(in: context)
        } catch {
            print("Planlı ödeme kaydedilirken hata: \(error)")
        }
    }
    
    func updateUserProfile(name: String, email: String?, profileImage: UIImage? = nil) {
        user.name = name
        user.email = email
        
        if let image = profileImage {
            if let imageData = image.jpegData(compressionQuality: 0.7) {
                user.profileImageData = imageData
            }
        }
        
        // Profil değişikliklerini kaydet
        saveUserProfile()
        
        // Değişiklikleri bildir
        objectWillChange.send()
    }
    
    private func saveUserProfile() {
        let defaults = UserDefaults.standard
        defaults.set(user.name, forKey: "userName")
        defaults.set(user.email, forKey: "userEmail")
        if let imageData = user.profileImageData {
            defaults.set(imageData, forKey: "userProfileImage")
        }
        defaults.synchronize()
    }
    
    // Profil bilgilerini yükle
    private func loadUserProfile() {
        let defaults = UserDefaults.standard
        if let name = defaults.string(forKey: "userName") {
            user.name = name
        }
        user.email = defaults.string(forKey: "userEmail")
        user.profileImageData = defaults.data(forKey: "userProfileImage")
    }
    
    // UIImage extension'ı için yardımcı computed property
    var profileImage: UIImage? {
        get {
            if let imageData = user.profileImageData {
                return UIImage(data: imageData)
            }
            return nil
        }
    }
    
    private func calculateCategoryExpenses() {
        let groupedTransactions = Dictionary(grouping: transactions) { $0.category }
        let totalExpense = transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        
        categoryExpenses = groupedTransactions.compactMap { category, transactions in
            let categoryTotal = transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
            let percentage = totalExpense > 0 ? min(max(0, (categoryTotal / totalExpense) * 100), 100) : 0
            return CategoryExpense(category: category, amount: categoryTotal, percentage: percentage)
        }
        .sorted { $0.amount > $1.amount }
    }
    
    /// Vadesi geçen ve ödenmemiş ödemeleri kontrol eder
    func checkOverduePayments() {
        let today = Date()
        let calendar = Calendar.current
        
        // Bütün planlı ödemeler içinde vadesi geçmiş ve ödenmemiş olanları filtrele
        let overdue = plannedPayments.filter { payment in
            let startOfDueDate = calendar.startOfDay(for: payment.dueDate)
            let startOfToday = calendar.startOfDay(for: today)
            return !payment.isPaid && startOfDueDate <= startOfToday
        }
        
        // Ana thread'de UI güncelleme
        DispatchQueue.main.async { [weak self] in
            self?.overduePayments = overdue
            
            // Vadesi geçmiş ödemeler varsa bildirim göster
            if !overdue.isEmpty {
                #if DEBUG
                print("Vadesi geçmiş \(overdue.count) adet ödeme bulundu")
                for payment in overdue {
                    print("- \(payment.title): \(payment.amount.formattedCurrency()) (\(payment.dueDate.formatted()))")
                }
                #endif
                
                // Uygulama içi bildirim buraya eklenebilir
            }
        }
    }
    
    /// Planlı ödemleri yeniden yükler ve vadesi geçenleri kontrol eder
    func refreshPayments() async {
        let context = persistenceController.container.viewContext
        await MainActor.run {
            fetchPlannedPayments(in: context)
        }
        checkOverduePayments()
    }
    
    // Planlı ödeme tamamlandığında işlem oluştur ve bakiyeyi güncelle
    func markPaymentAsCompleted(_ payment: PlannedPayment) {
        updatePlannedPayment(PlannedPayment(
            id: payment.id,
            title: payment.title,
            amount: payment.amount,
            dueDate: payment.dueDate,
            isPaid: true,
            note: payment.note,
            notificationPreferences: payment.notificationPreferences,
            isRecurring: payment.isRecurring,
            recurringInterval: payment.recurringInterval
        ))
        
        // Otomatik olarak bir gider işlemi oluştur
        addTransaction(
            title: payment.title,
            amount: payment.amount,
            type: .expense,
            category: "Planlı Ödeme",
            date: Date(),
            note: "Planlı ödeme: \(payment.title)"
        )
        
        // Bakiye otomatik olarak updateBalance() fonksiyonu ile güncellenecek
        // çünkü addTransaction zaten updateBalance()'i çağırıyor
    }
    
    func schedulePaymentNotifications(for payment: PlannedPayment) {
        let preferences = payment.notificationPreferences
        let content = UNMutableNotificationContent()
        content.sound = .default
        
        if preferences.oneWeek {
            scheduleNotification(
                for: payment,
                days: 7,
                content: content,
                identifier: "\(payment.id)-week"
            )
        }
        
        if preferences.threeDays {
            scheduleNotification(
                for: payment,
                days: 3,
                content: content,
                identifier: "\(payment.id)-threeDays"
            )
        }
        
        if preferences.oneDay {
            scheduleNotification(
                for: payment,
                days: 1,
                content: content,
                identifier: "\(payment.id)-oneDay"
            )
        }
    }
    
    private func scheduleNotification(
        for payment: PlannedPayment,
        days: Int,
        content: UNMutableNotificationContent,
        identifier: String
    ) {
        // Bildirim içeriğini ayarla
        content.title = "Finans Dostum"
        
        // Bildirim mesajını oluştur
        let formattedAmount = payment.amount.formattedCurrency()
        let message: String
        switch days {
        case 7:
            message = "\(payment.title) ödemesi için hatırlatma 📅\n\nTutar: \(formattedAmount)\nKalan süre: 1 hafta"
        case 3:
            message = "\(payment.title) ödemesi yaklaşıyor ⏰\n\nTutar: \(formattedAmount)\nKalan süre: 3 gün"
        case 1:
            message = "\(payment.title) ödemesi yarın ⚠️\n\nTutar: \(formattedAmount)\nLütfen ödemeyi unutmayın"
        default:
            message = "\(payment.title) ödemesi için\n\nTutar: \(formattedAmount)\nKalan süre: \(days) gün"
        }
        content.body = message
        
        // Bildirim sesi ve titreşim
        content.sound = .default
        content.categoryIdentifier = "PAYMENT_REMINDER"
        content.badge = 1
        
        // Gerçek bildirim zamanını ayarla
        let triggerDate = Calendar.current.date(
            byAdding: .day,
            value: -days,
            to: payment.dueDate
        ) ?? payment.dueDate
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: triggerDate
            ),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        // Bildirimi planla
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Bildirim planlanırken hata oluştu: \(error.localizedDescription)")
            }
        }
    }
    
    func checkPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            if requests.isEmpty {
                print("Bekleyen bildirim bulunmuyor")
            } else {
                print("Bekleyen Bildirimler (\(requests.count)):")
                for request in requests {
                    print("-------------------")
                    print("Bildirim ID: \(request.identifier)")
                    print("Başlık: \(request.content.title)")
                    print("Mesaj: \(request.content.body)")
                    if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                        print("Kalan süre: \(trigger.timeInterval) saniye")
                    }
                }
            }
        }
        
        // Bildirim izinlerini kontrol et
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Bildirim İzinleri:")
            print("Yetkilendirme Durumu: \(settings.authorizationStatus.rawValue)")
            print("Bildirim İzni: \(settings.notificationCenterSetting.rawValue)")
            print("Ses İzni: \(settings.soundSetting.rawValue)")
            print("Rozet İzni: \(settings.badgeSetting.rawValue)")
        }
    }
    
    // Verileri JSON olarak dışa aktar
    func exportData() {
        // Transaction verilerini dönüştür
        let transactionData = transactions.map { transaction in
            TransactionData(
                id: transaction.id,
                title: transaction.title,
                amount: transaction.amount,
                type: transaction.type == .income ? .income : .expense,
                category: transaction.category,
                date: transaction.date
            )
        }
        
        // PlannedPayment verilerini dönüştür
        let plannedPaymentData = plannedPayments.map { payment in
            PlannedPaymentData(
                id: payment.id,
                title: payment.title,
                amount: payment.amount,
                dueDate: payment.dueDate,
                isPaid: payment.isPaid,
                note: payment.note,
                isRecurring: payment.isRecurring,
                recurringInterval: payment.recurringInterval
            )
        }
        
        let categoryBudgetData = suggestedBudgets.map { budget in
            CategoryBudgetData(
                category: budget.category,
                suggestedAmount: budget.suggestedAmount,
                currentAmount: budget.currentAmount,
                progress: budget.progress
            )
        }
        
        let exportData = ExportData(
            transactions: transactionData,
            plannedPayments: plannedPaymentData,
            categoryBudgets: categoryBudgetData
        )
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(exportData)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm"
            let dateString = dateFormatter.string(from: Date())
            
            let fileName = "FinansDostu_Yedek_\(dateString).json"
            let tempDirectoryURL = FileManager.default.temporaryDirectory
            let fileURL = tempDirectoryURL.appendingPathComponent(fileName)
            
            try data.write(to: fileURL)
            
            DispatchQueue.main.async {
                let activityVC = UIActivityViewController(
                    activityItems: [fileURL],
                    applicationActivities: nil
                )
                
                // iPad için popover presentation
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootVC = window.rootViewController {
                    
                    // iPad için popover ayarları
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        activityVC.popoverPresentationController?.sourceView = window
                        activityVC.popoverPresentationController?.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                        activityVC.popoverPresentationController?.permittedArrowDirections = []
                    }
                    
                    rootVC.present(activityVC, animated: true) {
                        print("Paylaşım menüsü açıldı")
                    }
                }
            }
        } catch {
            print("Veri yedekleme hatası: \(error.localizedDescription)")
        }
    }
    
    // Verileri JSON'dan içe aktar
    func importData(from url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            // Önce verileri decode etmeyi dene
            let importData = try decoder.decode(ExportData.self, from: data)
            
            // Geçici bir context oluştur
            let tempContext = persistenceController.container.newBackgroundContext()
            
            tempContext.performAndWait {
                do {
                    // Mevcut verileri temizle
                    clearCoreData()
                    
                    // Yeni verileri ekle
                    importData.transactions.forEach { transactionData in
                        let entity = TransactionEntity(context: tempContext)
                        entity.id = transactionData.id
                        entity.title = transactionData.title
                        entity.amount = transactionData.amount
                        entity.type = transactionData.type == .income ? "income" : "expense"
                        entity.category = transactionData.category
                        entity.date = transactionData.date
                    }
                    
                    importData.plannedPayments.forEach { paymentData in
                        let entity = PlannedPaymentEntity(context: tempContext)
                        entity.id = paymentData.id
                        entity.title = paymentData.title
                        entity.amount = paymentData.amount
                        entity.dueDate = paymentData.dueDate
                        entity.isPaid = paymentData.isPaid
                        entity.note = paymentData.note
                        entity.isRecurring = paymentData.isRecurring
                        entity.recurringInterval = paymentData.recurringInterval
                    }
                    
                    // Değişiklikleri kaydet
                    try tempContext.save()
                    
                    // Ana thread'de UI'ı güncelle
                    DispatchQueue.main.async { [weak self] in
                        self?.fetchTransactions(in: tempContext)
                        self?.fetchPlannedPayments(in: tempContext)
                        self?.updateBudgetInsights()
                        
                        // Başarı mesajı göster
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first,
                           let rootVC = window.rootViewController {
                            
                            let alert = UIAlertController(
                                title: "Başarılı",
                                message: "Veriler başarıyla geri yüklendi",
                                preferredStyle: .alert
                            )
                            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
                            rootVC.present(alert, animated: true)
                        }
                    }
                } catch {
                    // Hata durumunda kullanıcıya bildir
                    DispatchQueue.main.async {
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first,
                           let rootVC = window.rootViewController {
                            
                            let alert = UIAlertController(
                                title: "Hata",
                                message: "Veriler geri yüklenirken bir hata oluştu: \(error.localizedDescription)",
                                preferredStyle: .alert
                            )
                            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
                            rootVC.present(alert, animated: true)
                        }
                    }
                }
            }
        } catch {
            // JSON decode hatası durumunda kullanıcıya bildir
            DispatchQueue.main.async {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootVC = window.rootViewController {
                    
                    let alert = UIAlertController(
                        title: "Hata",
                        message: "Yedek dosyası okunamadı: \(error.localizedDescription)",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "Tamam", style: .default))
                    rootVC.present(alert, animated: true)
                }
            }
        }
    }
    
    // Tüm verileri sıfırla
    func resetAllData() {
        clearCoreData()
        fetchTransactions(in: persistenceController.container.viewContext)
        fetchPlannedPayments(in: persistenceController.container.viewContext)
        updateBudgetInsights()
    }
    
    private func clearCoreData() {
        let context = persistenceController.container.viewContext
        
        // Tüm entity'leri temizle
        let entityNames = ["TransactionEntity", "PlannedPaymentEntity"]
        
        for entityName in entityNames {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(batchDeleteRequest)
                try context.save()
            } catch {
                print("Core Data temizleme hatası: \(error)")
            }
        }
    }
    
    // Async veri yükleme fonksiyonları
    @MainActor
    func loadTransactions() async {
        let context = persistenceController.container.newBackgroundContext()
        
        let request = NSFetchRequest<TransactionEntity>(entityName: "TransactionEntity")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TransactionEntity.date, ascending: false)]
        request.fetchBatchSize = 20
        
        do {
            let results = try await context.perform {
                try request.execute()
            }
            self.transactions = results.map { Transaction(from: $0) }
            self.filterTransactions()
        } catch {
            print("Error loading transactions: \(error)")
        }
    }
    
    @MainActor
    func loadPlannedPayments() async {
        let context = persistenceController.container.newBackgroundContext()
        
        let request = NSFetchRequest<PlannedPaymentEntity>(entityName: "PlannedPaymentEntity")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PlannedPaymentEntity.dueDate, ascending: true)]
        request.fetchBatchSize = 20
        
        do {
            let results = try await context.perform {
                try request.execute()
            }
            self.plannedPayments = results.map { entity in
                PlannedPayment(
                    id: entity.id ?? UUID(),
                    title: entity.title ?? "",
                    amount: entity.amount,
                    dueDate: entity.dueDate ?? Date(),
                    isPaid: entity.isPaid,
                    note: entity.note,
                    notificationPreferences: NotificationPreference(),
                    isRecurring: entity.isRecurring,
                    recurringInterval: entity.recurringInterval
                )
            }
        } catch {
            print("Error loading planned payments: \(error)")
        }
    }
}

// Paralel işlem için extension
extension Dictionary {
    func concurrentMap<T>(_ transform: (Key, Value) -> T) -> [T] {
        var results = [T]()
        let queue = DispatchQueue(label: "concurrent.queue", attributes: .concurrent)
        
        DispatchQueue.concurrentPerform(iterations: self.count) { index in
            let key = Array(self.keys)[index]
            if let value = self[key] {
                let result = transform(key, value)
                queue.async(flags: .barrier) {
                    results.append(result)
                }
            }
        }
        
        return results
    }
}

// Yedekleme için veri modelleri
struct ExportData: Codable {
    let transactions: [TransactionData]
    let plannedPayments: [PlannedPaymentData]
    let categoryBudgets: [CategoryBudgetData]
}

// Yedekleme için Transaction modeli
struct TransactionData: Codable {
    let id: UUID
    let title: String
    let amount: Double
    let type: TransactionType
    let category: String
    let date: Date
    
    enum TransactionType: String, Codable {
        case income
        case expense
    }
}

// Yedekleme için PlannedPayment modeli
struct PlannedPaymentData: Codable {
    let id: UUID
    let title: String
    let amount: Double
    let dueDate: Date
    let isPaid: Bool
    let note: String?
    let isRecurring: Bool
    let recurringInterval: String?
}

// Yedekleme için CategoryBudget modeli
struct CategoryBudgetData: Codable {
    let category: String
    let suggestedAmount: Double
    let currentAmount: Double
    let progress: Double
} 
