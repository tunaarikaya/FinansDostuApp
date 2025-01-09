import SwiftUI

struct BudgetSummaryView: View {
    let insights: [BudgetInsight]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bütçe Özeti")
                .font(.headline)
            
            ForEach(insights.prefix(3)) { insight in
                BudgetInsightRow(insight: insight)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct BudgetInsightRow: View {
    let insight: BudgetInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(insight.category)
                .font(.subheadline)
            Text(insight.message)
                .font(.caption)
                .foregroundColor(.secondary)
            
            ProgressView(value: insight.currentSpending, total: insight.suggestion)
                .tint(insight.trend == .increased ? .red : .green)
        }
    }
} 