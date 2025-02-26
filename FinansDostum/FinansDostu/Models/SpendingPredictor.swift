import Foundation

class SpendingPredictor {
    // Model input özellikleri
    struct ModelInput {
        let previousMonthSpending: Double
        let category: String
        let month: Int
        let income: Double
        let recurringPayments: Double
    }
    
    // Model output
    struct PredictionOutput {
        let predictedAmount: Double
        let confidence: Double
        let suggestedLimit: Double
    }
    
    // Kategori bazlı tahmin
    func predictSpending(for category: String,
                        basedOn historicalData: [Transaction],
                        income: Double,
                        recurringPayments: Double) -> PredictionOutput {
        
        // Basit tahmin algoritması
        let lastMonthSpending = calculateLastMonthSpending(for: category, from: historicalData)
        let currentMonth = Calendar.current.component(.month, from: Date())
        let seasonalFactor = getSeasonalFactor(for: currentMonth)
        
        let predictedAmount = lastMonthSpending * seasonalFactor
        let suggestedLimit = lastMonthSpending * 0.9 // %10 tasarruf hedefi
        let confidence = 0.7 // Sabit güven skoru
        
        return PredictionOutput(
            predictedAmount: predictedAmount,
            confidence: confidence,
            suggestedLimit: suggestedLimit
        )
    }
    
    private func calculateLastMonthSpending(for category: String, from transactions: [Transaction]) -> Double {
        let calendar = Calendar.current
        let now = Date()
        
        guard let lastMonthStart = calendar.date(byAdding: .month, value: -1, to: now),
              let lastMonthEnd = calendar.date(byAdding: .day, value: -1, to: now) else {
            return 0
        }
        
        let lastMonthTransactions = transactions.filter { transaction in
            transaction.category == category &&
            transaction.type == .expense &&
            transaction.date >= lastMonthStart &&
            transaction.date <= lastMonthEnd
        }
        
        return lastMonthTransactions.reduce(0) { $0 + $1.amount }
    }
    
    private func getSeasonalFactor(for month: Int) -> Double {
        let seasonalFactors: [Int: Double] = [
            12: 1.3, // Aralık
            1: 0.8,  // Ocak
            2: 0.9,  // Şubat
            3: 1.0,  // Mart
            4: 1.0,  // Nisan
            5: 1.1,  // Mayıs
            6: 1.2,  // Haziran
            7: 1.2,  // Temmuz
            8: 1.2,  // Ağustos
            9: 1.1,  // Eylül
            10: 1.0, // Ekim
            11: 1.1  // Kasım
        ]
        
        return seasonalFactors[month] ?? 1.0
    }
}

struct TrainingData {
    let previousSpending: [Double]
    let categories: [String]
    let months: [Int]
    let incomes: [Double]
    let recurringPayments: [Double]
    let actualSpendings: [Double]
} 