import SwiftUI

struct BudgetAssistantView: View {
    @StateObject var viewModel: MainViewModel
    @State private var selectedMonth = Date()
    @State private var showingExportAlert = false
    @State private var exportPath: String?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Üst Kısım - Ana Mesaj
                VStack(spacing: 10) {
                    Text("Akıllı Bütçe Asistanı")
                        .font(.title2.bold())
                    
                    Text("Geçmiş harcamalarınıza göre öneriler sunuyoruz")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        
                    Button(action: {
                        let exporter = SpendingDataExporter()
                        if let fileURL = exporter.saveToFile() {
                            exportPath = fileURL.path
                            showingExportAlert = true
                        }
                    }) {
                        Label("Verileri Dışa Aktar", systemImage: "square.and.arrow.up")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                
                // Kategori Bazlı Analizler
                VStack(alignment: .leading, spacing: 15) {
                    Text("Kategori Analizleri")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(viewModel.categoryInsights) { insight in
                        CategoryInsightCard(insight: insight)
                    }
                }
                
                // Önerilen Bütçeler
                VStack(alignment: .leading, spacing: 15) {
                    Text("Önerilen Bütçeler")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(viewModel.suggestedBudgets) { budget in
                        BudgetProgressCard(budget: budget)
                    }
                }
                
                // Tasarruf İpuçları
                if let savingTip = viewModel.currentSavingTip {
                    TipCard(message: savingTip)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Bütçe Asistanı")
        .alert("Dışa Aktarma Başarılı", isPresented: $showingExportAlert) {
            Button("Tamam", role: .cancel) { }
        } message: {
            if let path = exportPath {
                Text("CSV dosyası şuraya kaydedildi:\n\(path)")
            }
        }
    }
}

struct CategoryInsightCard: View {
    let insight: BudgetInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
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
                Text("Önerilen limit: \(String(format: "%.2f ₺", insight.suggestion))")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

struct BudgetProgressCard: View {
    let budget: CategoryBudget
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(budget.category)
                    .font(.headline)
                Spacer()
                Text(String(format: "%.2f ₺", budget.currentAmount))
                    .font(.headline)
            }
            
            ProgressView(value: budget.progress)
                .tint(budget.progress > 1.0 ? .red : .blue)
            
            Text("Önerilen: \(String(format: "%.2f ₺", budget.suggestedAmount))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

struct TipCard: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.yellow)
            Text(message)
                .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
} 