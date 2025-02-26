import SwiftUI

struct BudgetSummaryView: View {
    let insights: [BudgetInsight]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Aylık Özet
            if let topInsight = insights.first {
                MonthlyOverview(insight: topInsight)
            }
            
            // Kategori Analizleri
            VStack(alignment: .leading, spacing: 12) {
                Text("Kategori Analizleri")
                    .font(.headline)
                
                if insights.isEmpty {
                    Text("Henüz yeterli veri bulunmuyor")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 12)
                } else {
                    ForEach(insights.prefix(3)) { insight in
                        CategoryInsightRow(insight: insight)
                        
                        if insight.id != insights.prefix(3).last?.id {
                            Divider()
                        }
                    }
                }
            }
            
            // Tasarruf Önerileri
            if !insights.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Akıllı Öneriler")
                        .font(.headline)
                    
                    ForEach(getSavingTips(from: insights), id: \.self) { tip in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundStyle(.yellow)
                                .font(.caption)
                            
                            Text(tip)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private func getSavingTips(from insights: [BudgetInsight]) -> [String] {
        var tips: [String] = []
        
        // En çok artış gösteren kategoriler için öneriler
        let increasedCategories = insights.filter { $0.trend == .increased }
        if let topIncrease = increasedCategories.max(by: { $0.currentSpending < $1.currentSpending }) {
            tips.append("\(topIncrease.category) harcamalarınız geçen aya göre artış gösterdi. Bu kategoriyi gözden geçirmenizi öneririz.")
        }
        
        // Başarılı tasarruf kategorileri
        let decreasedCategories = insights.filter { $0.trend == .decreased }
        if let topDecrease = decreasedCategories.max(by: { $0.previousSpending - $0.currentSpending < $1.previousSpending - $1.currentSpending }) {
            tips.append("\(topDecrease.category) kategorisinde başarılı bir tasarruf sağladınız. Bu şekilde devam edin!")
        }
        
        // Genel bütçe durumu
        let totalCurrentSpending = insights.reduce(0) { $0 + $1.currentSpending }
        let totalPreviousSpending = insights.reduce(0) { $0 + $1.previousSpending }
        
        if totalCurrentSpending > totalPreviousSpending {
            tips.append("Bu ay genel harcamalarınızda artış var. Gereksiz harcamaları azaltmayı düşünebilirsiniz.")
        } else if totalCurrentSpending < totalPreviousSpending {
            tips.append("Tebrikler! Bu ay genel harcamalarınızı azaltmayı başardınız.")
        }
        
        return tips
    }
}

struct MonthlyOverview: View {
    let insight: BudgetInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bu Ay")
                        .font(.headline)
                    Text(Date().formatted(.dateTime.month(.wide)))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Trend göstergesi
                HStack(spacing: 4) {
                    Image(systemName: insight.trend == .increased ? "arrow.up.circle.fill" : 
                                    insight.trend == .decreased ? "arrow.down.circle.fill" : "equal.circle.fill")
                        .foregroundStyle(insight.trend == .increased ? .red :
                                       insight.trend == .decreased ? .green : .blue)
                    
                    Text(getPercentageChange(current: insight.currentSpending, previous: insight.previousSpending))
                        .font(.callout.bold())
                        .foregroundStyle(insight.trend == .increased ? .red :
                                       insight.trend == .decreased ? .green : .blue)
                }
            }
            
            // İlerleme çubuğu
            ProgressView(value: min(insight.currentSpending, insight.suggestion), total: insight.suggestion)
                .tint(insight.trend == .increased ? .red : .blue)
            
            // Harcama detayları
            HStack {
                VStack(alignment: .leading) {
                    Text("Mevcut")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.2f ₺", insight.currentSpending))
                        .font(.subheadline.bold())
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Önerilen")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.2f ₺", insight.suggestion))
                        .font(.subheadline.bold())
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func getPercentageChange(current: Double, previous: Double) -> String {
        guard previous > 0 else { return "0%" }
        let percentage = ((current - previous) / previous) * 100
        return String(format: "%.1f%%", abs(percentage))
    }
}

struct CategoryInsightRow: View {
    let insight: BudgetInsight
    
    private var progressValue: Double {
        if insight.suggestion <= 0 { return 0 }
        return min(max(0, insight.currentSpending), insight.suggestion)
    }
    
    private var progressTotal: Double {
        max(insight.suggestion, 0.01)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(insight.category)
                    .font(.headline)
                
                Spacer()
                
                // Trend göstergesi
                HStack(spacing: 4) {
                    Image(systemName: insight.trend == .increased ? "arrow.up.circle.fill" : 
                                    insight.trend == .decreased ? "arrow.down.circle.fill" : "equal.circle.fill")
                        .foregroundStyle(insight.trend == .increased ? .red :
                                       insight.trend == .decreased ? .green : .blue)
                }
            }
            
            Text(insight.message)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            ProgressView(value: progressValue, total: progressTotal)
                .tint(insight.trend == .increased ? .red : .blue)
            
            HStack {
                Text(String(format: "%.2f ₺", insight.currentSpending))
                    .font(.subheadline)
                    .foregroundStyle(insight.trend == .increased ? .red : .primary)
                
                Spacer()
                
                Text("Hedef: \(String(format: "%.2f ₺", insight.suggestion))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
