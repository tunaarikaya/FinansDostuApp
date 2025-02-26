import Foundation

struct BudgetInsight: Identifiable {
    let id: UUID
    let category: String
    let currentSpending: Double
    let previousSpending: Double
    let trend: Trend
    let message: String
    let suggestion: Double
    
    enum Trend {
        case increased
        case decreased
        case stable
        
        var description: String {
            switch self {
            case .increased:
                return "Artış"
            case .decreased:
                return "Azalış"
            case .stable:
                return "Sabit"
            }
        }
        
        var icon: String {
            switch self {
            case .increased:
                return "arrow.up.circle.fill"
            case .decreased:
                return "arrow.down.circle.fill"
            case .stable:
                return "equal.circle.fill"
            }
        }
    }
    
    var percentageChange: Double {
        guard previousSpending > 0 else { return 0 }
        return ((currentSpending - previousSpending) / previousSpending) * 100
    }
    
    var isOverBudget: Bool {
        currentSpending > suggestion
    }
    
    var progressPercentage: Double {
        guard suggestion > 0 else { return 0 }
        return min((currentSpending / suggestion) * 100, 100)
    }
    
    var remainingBudget: Double {
        max(suggestion - currentSpending, 0)
    }
    
    var savingOpportunity: Double {
        if trend == .increased {
            return currentSpending - previousSpending
        }
        return 0
    }
    
    func getDetailedAnalysis() -> String {
        var analysis = ""
        
        // Trend analizi
        switch trend {
        case .increased:
            analysis += "Bu kategoride harcamalarınız geçen aya göre %\(String(format: "%.1f", abs(percentageChange))) arttı. "
            if isOverBudget {
                analysis += "Bütçenizi aştınız ve \(String(format: "%.2f ₺", currentSpending - suggestion)) fazla harcama yaptınız."
            }
        case .decreased:
            analysis += "Tebrikler! Bu kategoride harcamalarınız geçen aya göre %\(String(format: "%.1f", abs(percentageChange))) azaldı. "
            analysis += "Bu şekilde devam ederseniz aylık \(String(format: "%.2f ₺", previousSpending - currentSpending)) tasarruf edebilirsiniz."
        case .stable:
            analysis += "Bu kategorideki harcamalarınız geçen ayla benzer seviyede. "
            if !isOverBudget {
                analysis += "Bütçe hedeflerinize uygun ilerliyorsunuz."
            }
        }
        
        return analysis
    }
    
    func getSavingTip() -> String {
        switch trend {
        case .increased:
            return "Bu kategoride tasarruf için alternatif seçenekleri değerlendirebilir veya harcamalarınızı erteleyebilirsiniz."
        case .decreased:
            return "Başarılı tasarruf stratejinizi diğer kategorilere de uygulayabilirsiniz."
        case .stable:
            return "Düzenli harcama alışkanlığınızı koruyun ve fırsatları değerlendirin."
        }
    }
}

struct CategoryBudget: Identifiable {
    let id: UUID
    let category: String
    let suggestedAmount: Double
    let currentAmount: Double
    let progress: Double
} 
