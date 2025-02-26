import SwiftUI

struct BudgetAssistantView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var selectedCategory: String?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Üst Kısım - Ana Mesaj
                VStack(spacing: 10) {
                    Text("Akıllı Bütçe Asistanı")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    
                    Text("Geçmiş harcamalarınıza göre öneriler sunuyoruz")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(20)
                .shadow(radius: 5)
                .padding(.horizontal)
                
                // Kategori Bazlı Analizler
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Image(systemName: "chart.pie.fill")
                            .foregroundStyle(.orange)
                        Text("Kategori Analizleri")
                            .font(.headline)
                    }
                    .padding(.horizontal)
                    
                    ForEach(viewModel.categoryInsights) { insight in
                        BudgetInsightCard(insight: insight)
                            .padding(.horizontal)
                    }
                }
                
                // Önerilen Bütçeler
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Image(systemName: "chart.bar.fill")
                            .foregroundStyle(.green)
                        Text("Önerilen Bütçeler")
                            .font(.headline)
                    }
                    .padding(.horizontal)
                    
                    ForEach(viewModel.suggestedBudgets) { budget in
                        BudgetProgressCard(budget: budget)
                    }
                }
                
                // Tasarruf İpuçları
                if let savingTip = viewModel.currentSavingTip {
                    TipCard(message: savingTip)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Bütçe Asistanı")
        .onAppear {
            // Sadece ilk açılışta verileri yükle
            if viewModel.categoryInsights.isEmpty {
                viewModel.updateBudgetInsights()
            }
        }
    }
}

struct CategoryInsightCard: View {
    let insight: BudgetInsight
    
    var cardColor: Color {
        switch insight.trend {
        case .increased:
            return .red.opacity(0.1)
        case .decreased:
            return .green.opacity(0.1)
        case .stable:
            return .blue.opacity(0.1)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: insight.trend == .increased ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                    .foregroundStyle(insight.trend == .increased ? .red : .green)
                Text(insight.category)
                    .font(.headline)
                Spacer()
                Text(String(format: "%.2f ₺", insight.currentSpending))
                    .font(.headline)
                    .foregroundColor(insight.trend == .increased ? .red : .green)
            }
            
            Text(insight.message)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if insight.suggestion > 0 {
                HStack {
                    Image(systemName: "target")
                        .foregroundStyle(.blue)
                    Text("Önerilen limit: \(String(format: "%.2f ₺", insight.suggestion))")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }
        }
        .padding()
        .background(cardColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

struct BudgetProgressCard: View {
    let budget: CategoryBudget
    
    var progressColor: Color {
        let progress = budget.progress
        if progress > 1.0 {
            return .red
        } else if progress > 0.8 {
            return .orange
        } else {
            return .blue
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "banknote.fill")
                    .foregroundStyle(progressColor)
                Text(budget.category)
                    .font(.headline)
                Spacer()
                Text(String(format: "%.2f ₺", budget.currentAmount))
                    .font(.headline)
            }
            
            ProgressView(value: budget.progress)
                .tint(progressColor)
            
            HStack {
                Image(systemName: "target")
                    .foregroundStyle(.secondary)
                Text("Önerilen: \(String(format: "%.2f ₺", budget.suggestedAmount))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(progressColor.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

struct TipCard: View {
    let message: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .font(.title2)
                .foregroundStyle(.yellow)
                .padding(10)
                .background(Color.yellow.opacity(0.2))
                .clipShape(Circle())
            
            Text(message)
                .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .yellow.opacity(0.1), radius: 5)
        .padding(.horizontal)
    }
} 