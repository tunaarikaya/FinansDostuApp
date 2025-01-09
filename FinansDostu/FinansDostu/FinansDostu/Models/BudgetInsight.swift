import Foundation

struct BudgetInsight: Identifiable {
    let id: UUID
    let category: String
    let currentSpending: Double
    let trend: Trend
    let message: String
    let suggestion: Double
    
    enum Trend {
        case increased
        case decreased
        case stable
    }
}

struct CategoryBudget: Identifiable {
    let id: UUID
    let category: String
    let suggestedAmount: Double
    let currentAmount: Double
    let progress: Double
} 
