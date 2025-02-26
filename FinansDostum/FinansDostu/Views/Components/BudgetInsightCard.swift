import SwiftUI
import Foundation

struct BudgetInsightCard: View {
    let insight: BudgetInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(insight.category)
                    .font(.headline)
                Spacer()
                Text(insight.trend == .increased ? "↑ Artış" : "↓ Azalış")
                    .foregroundStyle(insight.trend == .increased ? .red : .green)
            }
            
            ProgressView(value: insight.currentSpending, total: insight.suggestion)
                .tint(insight.trend == .increased ? .red : .green)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Harcama")
                        .font(.caption)
                    Text(insight.currentSpending.formattedCurrency())
                        .font(.subheadline.bold())
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Öneri")
                        .font(.caption)
                    Text(insight.suggestion.formattedCurrency())
                        .font(.subheadline.bold())
                }
            }
            
            Text(insight.message)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
} 
