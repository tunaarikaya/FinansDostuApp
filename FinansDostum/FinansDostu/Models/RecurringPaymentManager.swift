import Foundation
import CoreData

/// Tekrarlayan ödemeleri yöneten sınıf
final class RecurringPaymentManager {
    private let persistenceController: PersistenceController
    private let calendar: Calendar
    
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
        self.calendar = Calendar.current
    }
    
    /// Yeni bir tekrarlayan ödeme serisi oluşturur
    func createRecurringPayment(
        title: String,
        amount: Double,
        startDate: Date,
        interval: String,
        note: String?,
        in context: NSManagedObjectContext
    ) throws {
        // İlk ödemeyi oluştur
        let firstPayment = PlannedPaymentEntity(context: context)
        firstPayment.id = UUID()
        firstPayment.title = title
        firstPayment.amount = amount
        firstPayment.dueDate = startDate
        firstPayment.note = note
        firstPayment.isRecurring = true
        firstPayment.recurringInterval = interval
        firstPayment.isPaid = false
        
        // Gelecek 12 ay için ödemeleri oluştur
        var currentDate = startDate
        for _ in 1...11 {
            guard let nextDate = calculateNextDueDate(from: currentDate, interval: interval) else { break }
            
            let payment = PlannedPaymentEntity(context: context)
            payment.id = UUID()
            payment.title = title
            payment.amount = amount
            payment.dueDate = nextDate
            payment.note = note
            payment.isRecurring = true
            payment.recurringInterval = interval
            payment.isPaid = false
            
            currentDate = nextDate
        }
        
        try context.save()
    }
    
    /// Tekrarlayan ödemeleri işler ve gerekli güncellemeleri yapar
    func processRecurringPayments() throws {
        let context = persistenceController.container.viewContext
        let request = NSFetchRequest<PlannedPaymentEntity>(entityName: "PlannedPaymentEntity")
        request.predicate = NSPredicate(format: "isRecurring == YES AND isPaid == NO")
        
        do {
            let recurringPayments = try context.fetch(request)
            let today = Date()
            
            // Ödemeleri kontrol et ve sadece yeni ödemeleri oluştur, otomatik ödeme yapma
            var madeChanges = false
            
            for payment in recurringPayments {
                guard let dueDate = payment.dueDate else { continue }
                
                let startOfDueDate = calendar.startOfDay(for: dueDate)
                let startOfToday = calendar.startOfDay(for: today)
                
                // Eğer ödeme tarihi geçmişse - sadece tekrarlayan ödemeleri denetliyoruz
                // Burada sadece tekrarlayan ödemeleri işliyor, onları otomatik olarak ödemiyor
                if startOfDueDate <= startOfToday {
                    // Burada otomatik ödeme işaretleme işlemini kaldırıyoruz
                    // payment.isPaid = true kodu ve createTransaction(for:in:) çağrısı kaldırıldı
                    
                    // Ödeme zamanı geçmiş ödemeler için sadece değişiklik yapıldığını işaretle
                    madeChanges = true
                }
            }
            
            // Sadece yeni tekrarlayan ödeme oluşturma işlemi yapılmışsa kaydet
            if madeChanges {
                try context.save()
                NotificationCenter.default.post(name: .recurringPaymentsProcessed, object: nil)
            }
        } catch {
            throw FinansError.recurringPaymentError("Tekrarlayan ödemeler işlenirken hata: \(error.localizedDescription)")
        }
    }
    
    /// Ödeme için işlem kaydı oluşturur
    private func createTransaction(for payment: PlannedPaymentEntity, in context: NSManagedObjectContext) {
        let transaction = TransactionEntity(context: context)
        transaction.id = UUID()
        transaction.title = payment.title ?? "Tekrarlayan Ödeme"
        transaction.amount = payment.amount
        transaction.type = "expense"
        transaction.date = Date()
        transaction.category = "Tekrarlayan Ödemeler"
    }
    
    /// Sonraki ödeme tarihini hesaplar
    private func calculateNextDueDate(from date: Date, interval: String) -> Date? {
        let components = calendar.dateComponents([.day, .month, .year], from: date)
        var nextComponents = DateComponents()
        
        switch interval {
        case "week":
            return calendar.date(byAdding: .day, value: 7, to: date)
            
        case "month":
            // Aynı günde bir sonraki ay
            nextComponents.day = components.day
            nextComponents.month = (components.month ?? 1) + 1
            nextComponents.year = components.year
            
            // Yıl geçişi kontrolü
            if nextComponents.month ?? 1 > 12 {
                nextComponents.month = 1
                nextComponents.year = (components.year ?? 0) + 1
            }
            
            // Ayın son günü kontrolü
            if let nextDate = calendar.date(from: nextComponents),
               let lastDayOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1),
                                                to: calendar.date(from: DateComponents(year: nextComponents.year,
                                                                                    month: nextComponents.month))!) {
                let lastDay = calendar.component(.day, from: lastDayOfMonth)
                if (components.day ?? 1) > lastDay {
                    nextComponents.day = lastDay
                }
            }
            
            return calendar.date(from: nextComponents)
            
        case "year":
            // Aynı gün ve ayda bir sonraki yıl
            nextComponents.day = components.day
            nextComponents.month = components.month
            nextComponents.year = (components.year ?? 0) + 1
            return calendar.date(from: nextComponents)
            
        default:
            return nil
        }
    }
}

// MARK: - Notifications
extension Notification.Name {
    static let recurringPaymentsProcessed = Notification.Name("recurringPaymentsProcessed")
} 