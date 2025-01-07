import Foundation
import CoreData

struct Transaction: Identifiable {
    let id: UUID
    var amount: Double
    var title: String
    var type: TransactionType
    var date: Date
    var category: String
    
    enum TransactionType: String {
        case income = "income"
        case expense = "expense"
    }
} 