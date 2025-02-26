import Foundation
import CoreData

struct Transaction: Identifiable {
    let id: UUID
    var amount: Double
    var title: String
    let type: TransactionType
    let date: Date
    let category: String
    let note: String?
    
    enum TransactionType: String {
        case income
        case expense
    }
    
    init(id: UUID = UUID(), amount: Double, title: String, type: TransactionType, date: Date = Date(), category: String = "Diğer", note: String? = nil) {
        self.id = id
        self.amount = amount
        self.title = title
        self.type = type
        self.date = date
        self.category = category
        self.note = note
    }
    
    init(from entity: TransactionEntity) {
        self.id = entity.id ?? UUID()
        self.amount = entity.amount
        self.title = entity.title ?? ""
        self.type = TransactionType(rawValue: entity.type ?? "expense") ?? .expense
        self.date = entity.date ?? Date()
        self.category = entity.category ?? "Diğer"
        self.note = entity.note
    }
} 