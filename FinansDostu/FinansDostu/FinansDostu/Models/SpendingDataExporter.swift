import Foundation
import CoreData

class SpendingDataExporter {
    let persistenceController: PersistenceController
    
    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
    }
    
    func exportToCSV() -> String? {
        let context = persistenceController.container.viewContext
        
        // CSV başlık satırı
        var csvString = "previousSpending,category,month,income,recurringPayments,actualSpendings\n"
        
        // TransactionEntity'den verileri çek
        let fetchRequest: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        
        do {
            let transactions = try context.fetch(fetchRequest)
            let sortedTransactions = transactions.sorted { $0.date ?? Date() < $1.date ?? Date() }
            
            // Her işlem için önceki ayın harcamasını takip et
            var previousMonthSpending: Double = 0
            var currentMonth = Calendar.current.component(.month, from: sortedTransactions.first?.date ?? Date())
            var currentMonthSpending: Double = 0
            
            for transaction in sortedTransactions {
                guard let date = transaction.date else { continue }
                let month = Calendar.current.component(.month, from: date)
                
                // Ay değiştiğinde önceki ay verilerini güncelle
                if month != currentMonth {
                    previousMonthSpending = currentMonthSpending
                    currentMonthSpending = 0
                    currentMonth = month
                }
                
                // Planlı ödemeleri hesapla
                let plannedPaymentsFetch: NSFetchRequest<PlannedPaymentEntity> = NSFetchRequest(entityName: "PlannedPaymentEntity")
                plannedPaymentsFetch.predicate = NSPredicate(format: "isPaid == %@", NSNumber(value: false))
                let plannedPayments = try context.fetch(plannedPaymentsFetch)
                let recurringPaymentsTotal = plannedPayments
                    .filter { payment in
                        if let dueDate = payment.dueDate {
                            return Calendar.current.component(.month, from: dueDate) == month
                        }
                        return false
                    }
                    .reduce(0) { $0 + $1.amount }
                
                // Geliri hesapla (pozitif işlemler)
                let income = transaction.amount >= 0 ? transaction.amount : 0
                
                // Harcamayı hesapla (negatif işlemler)
                let spending = transaction.amount < 0 ? abs(transaction.amount) : 0
                currentMonthSpending += spending
                
                // CSV satırını oluştur
                let csvLine = String(format: "%.2f,%@,%d,%.2f,%.2f,%.2f\n",
                                  previousMonthSpending,
                                  transaction.category ?? "Diğer",
                                  month,
                                  income,
                                  recurringPaymentsTotal,
                                  spending)
                
                csvString += csvLine
            }
            
            return csvString
            
        } catch {
            print("Veri çekerken hata oluştu: \(error)")
            return nil
        }
    }
    
    func saveToFile() -> URL? {
        guard let csvString = exportToCSV() else { return nil }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsPath.appendingPathComponent("spending_data.csv")
        
        do {
            try csvString.write(to: filePath, atomically: true, encoding: .utf8)
            return filePath
        } catch {
            print("CSV dosyası kaydedilirken hata oluştu: \(error)")
            return nil
        }
    }
} 