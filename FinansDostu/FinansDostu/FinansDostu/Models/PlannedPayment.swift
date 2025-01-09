import Foundation
struct PlannedPayment: Identifiable {
    let id: UUID
    var title: String
    var amount: Double
    var dueDate: Date
    var note: String?
    var isRecurring: Bool
    var recurringInterval: String?
    var isPaid: Bool
} 
