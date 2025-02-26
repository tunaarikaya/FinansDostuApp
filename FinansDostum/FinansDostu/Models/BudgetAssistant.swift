import Foundation

struct MonthlyAnalysis {
    let totalSpending: Double
    let biggestCategory: String
    let savingsPotential: Double
    let insights: [BudgetInsight]
    let suggestedBudgets: [CategoryBudget]
    
    var mainMessage: String {
        if savingsPotential > 0 {
            return "Bu ay \(String(format: "%.2f ₺", savingsPotential)) tasarruf potansiyeli tespit ettik!"
        } else {
            return "Harika! Bütçenizi iyi yönetiyorsunuz."
        }
    }
}

class BudgetAssistant {
    func analyzeMonthlySpending(
        transactions: [Transaction],
        plannedPayments: [PlannedPayment]
    ) -> MonthlyAnalysis {
        let totalSpending = transactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
        
        let categorySpending = Dictionary(grouping: transactions.filter { $0.type == .expense }) { $0.category }
            .mapValues { transactions in
                transactions.reduce(0) { $0 + $1.amount }
            }
        
        let biggestCategory = categorySpending
            .max(by: { $0.value < $1.value })?
            .key ?? "Diğer"
        
        let insights = createInsights(from: transactions)
        let suggestedBudgets = createBudgets(from: insights)
        
        let savingsPotential = calculateSavingsPotential(
            currentSpending: totalSpending,
            suggestedBudgets: suggestedBudgets
        )
        
        return MonthlyAnalysis(
            totalSpending: totalSpending,
            biggestCategory: biggestCategory,
            savingsPotential: savingsPotential,
            insights: insights,
            suggestedBudgets: suggestedBudgets
        )
    }
    
    private func createInsights(from transactions: [Transaction]) -> [BudgetInsight] {
        let categories = Set(transactions.map { $0.category })
        
        return categories.map { category in
            let categoryTransactions = transactions.filter { $0.category == category && $0.type == .expense }
            let currentSpending = categoryTransactions.reduce(0) { $0 + $1.amount }
            let previousSpending = calculatePreviousMonthSpending(for: categoryTransactions)
            
            let trend: BudgetInsight.Trend = currentSpending > previousSpending ? .increased : .decreased
            
            let suggestion = calculateSuggestedLimit(
                currentSpending: currentSpending,
                previousSpending: previousSpending
            )
            
            let message = createMessage(
                category: category,
                currentSpending: currentSpending,
                previousSpending: previousSpending,
                trend: trend
            )
            
            return BudgetInsight(
                id: UUID(),
                category: category,
                currentSpending: currentSpending,
                previousSpending: previousSpending,
                trend: trend,
                message: message,
                suggestion: suggestion
            )
        }
    }
    
    private func createBudgets(from insights: [BudgetInsight]) -> [CategoryBudget] {
        return insights.map { insight in
            CategoryBudget(
                id: UUID(),
                category: insight.category,
                suggestedAmount: insight.suggestion,
                currentAmount: insight.currentSpending,
                progress: insight.suggestion > 0 ? insight.currentSpending / insight.suggestion : 1
            )
        }
    }
    
    private func calculatePreviousMonthSpending(for transactions: [Transaction]) -> Double {
        let calendar = Calendar.current
        let currentDate = Date()
        let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentDate)!
        
        let previousMonthTransactions = transactions.filter {
            calendar.component(.month, from: $0.date) == calendar.component(.month, from: previousMonth)
        }
        
        return previousMonthTransactions.reduce(0) { $0 + $1.amount }
    }
    
    private func calculateSuggestedLimit(currentSpending: Double, previousSpending: Double) -> Double {
        if currentSpending > previousSpending * 1.2 {
            return previousSpending * 1.1 // %10 tolerans
        } else if currentSpending < previousSpending * 0.8 {
            return currentSpending * 1.1 // Mevcut harcamaya %10 tolerans
        } else {
            return currentSpending // Harcama normal aralıktaysa aynı kalsın
        }
    }
    
    private func calculateSavingsPotential(currentSpending: Double, suggestedBudgets: [CategoryBudget]) -> Double {
        let totalSuggested = suggestedBudgets.reduce(0) { $0 + $1.suggestedAmount }
        return max(0, currentSpending - totalSuggested)
    }
    
    private func createMessage(category: String, currentSpending: Double, previousSpending: Double, trend: BudgetInsight.Trend) -> String {
        let difference = abs(currentSpending - previousSpending)
        let percentChange = previousSpending > 0 ? (difference / previousSpending) * 100 : 0
        
        switch trend {
        case .increased:
            return String(format: "%@ kategorisinde geçen aya göre %.1f%% daha fazla harcama yaptınız.", category, percentChange)
        case .decreased:
            return String(format: "%@ kategorisinde geçen aya göre %.1f%% daha az harcama yaptınız.", category, percentChange)
        case .stable:
            return String(format: "%@ kategorisindeki harcamalarınız geçen ayla aynı seviyede.", category)
        }
    }
} 
