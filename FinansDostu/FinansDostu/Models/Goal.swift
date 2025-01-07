import Foundation
enum GoalCategory: String, CaseIterable {
    case tasarruf = "Tasarruf"
    case yatirim = "Yatırım"
    case tatil = "Tatil"
    case egitim = "Eğitim"
    case ev = "Ev"
    case araba = "Araba"
    case diger = "Diğer"
}

struct Goal: Identifiable {
    let id: UUID
    var title: String
    var targetAmount: Double
    var savedAmount: Double
    var dueDate: Date
    var note: String?
    var category: GoalCategory
    var monthlyContributions: [Double] = []  // Aylık katkılar geçmişi
    var lastUpdateDate: Date = Date()
    
    var progress: Double {
        savedAmount / targetAmount
    }
    
    var remainingDays: String {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
        if days < 0 {
            return "Süre doldu"
        } else if days == 0 {
            return "Son gün"
        } else {
            return "\(days) gün kaldı"
        }
    }
    
    var isUrgent: Bool {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
        return days <= 7 && progress < 1.0
    }
    
    var averageMonthlyContribution: Double {
        guard !monthlyContributions.isEmpty else { return 0 }
        return monthlyContributions.reduce(0, +) / Double(monthlyContributions.count)
    }
    
    var requiredMonthlyContribution: Double {
        let remainingAmount = targetAmount - savedAmount
        let months = Calendar.current.dateComponents([.month], from: Date(), to: dueDate).month ?? 1
        return remainingAmount / Double(max(1, months))
    }
    
    var isOnTrack: Bool {
        let monthlyNeeded = requiredMonthlyContribution
        return averageMonthlyContribution >= monthlyNeeded
    }
} 
