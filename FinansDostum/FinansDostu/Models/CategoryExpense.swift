import Foundation

public struct CategoryExpense: Identifiable, Equatable {
    public let id: UUID
    public let category: String
    public let amount: Double
    public let percentage: Double
    
    public init(id: UUID = UUID(), category: String, amount: Double, percentage: Double) {
        self.id = id
        self.category = category
        self.amount = amount
        self.percentage = percentage
    }
    
    public static func == (lhs: CategoryExpense, rhs: CategoryExpense) -> Bool {
        lhs.id == rhs.id
    }
} 
