import SwiftUI
import Charts

struct GraphView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @Environment(\.colorScheme) var colorScheme
    
    private let months = [
        "Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran",
        "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Ay Seçici
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(1...12, id: \.self) { month in
                            MonthButton(
                                monthName: months[month - 1],
                                isSelected: selectedMonth == month
                            ) {
                                selectedMonth = month
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // Seçili Ay için Harcama Özeti
                MonthlyExpenseSummary(month: selectedMonth, viewModel: viewModel)
                
                // Kategori Bazlı Harcamalar
                CategoryExpenseChart(month: selectedMonth, viewModel: viewModel)
                
                // Detaylı Kategori Listesi
                CategoryListView(month: selectedMonth, viewModel: viewModel)
            }
            .padding(.vertical)
        }
        .navigationTitle("Finansal Analiz")
        .background(Color(.systemGroupedBackground))
    }
}

struct MonthButton: View {
    let monthName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(monthName)
                .font(.system(.callout, design: .rounded))
                .fontWeight(isSelected ? .bold : .medium)
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue : Color.clear)
                )
                .overlay(
                    Capsule()
                        .strokeBorder(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

struct MonthlyExpenseSummary: View {
    let month: Int
    @ObservedObject var viewModel: MainViewModel
    
    private var monthlyTransactions: [Transaction] {
        viewModel.transactions.filter {
            Calendar.current.component(.month, from: $0.date) == month
        }
    }
    
    private var totalIncome: Double {
        monthlyTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }
    
    private var totalExpense: Double {
        monthlyTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Gelir")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("₺\(String(format: "%.2f", totalIncome))")
                        .font(.title2.bold())
                        .foregroundStyle(.green)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text("Gider")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("₺\(String(format: "%.2f", totalExpense))")
                        .font(.title2.bold())
                        .foregroundStyle(.red)
                }
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
        }
    }
}

struct CategoryExpenseChart: View {
    let month: Int
    @ObservedObject var viewModel: MainViewModel
    
    private var monthlyExpenses: [CategoryExpense] {
        let transactions = viewModel.transactions.filter {
            Calendar.current.component(.month, from: $0.date) == month &&
            $0.type == .expense
        }
        
        let groupedTransactions = Dictionary(grouping: transactions) { $0.category }
        let totalExpense = transactions.reduce(0) { $0 + $1.amount }
        
        return groupedTransactions.map { category, transactions in
            let amount = transactions.reduce(0) { $0 + $1.amount }
            let percentage = totalExpense > 0 ? (amount / totalExpense) * 100 : 0
            return CategoryExpense(category: category, amount: amount, percentage: percentage)
        }.sorted { $0.amount > $1.amount }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Harcama Dağılımı")
                .font(.headline)
                .padding(.horizontal)
            
            if monthlyExpenses.isEmpty {
                Text("Bu ay için harcama verisi bulunmuyor")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                Chart(monthlyExpenses) { category in
                    SectorMark(
                        angle: .value("Harcama", category.percentage),
                        innerRadius: .ratio(0.6),
                        angularInset: 2.0
                    )
                    .cornerRadius(6)
                    .foregroundStyle(categoryColor(for: category.category))
                }
                .frame(height: 220)
                .padding(.vertical)
            }
        }
        .padding(.vertical)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
    
    private func categoryColor(for category: String) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .yellow]
        let index = abs(category.hashValue) % colors.count
        return colors[index]
    }
}

struct CategoryListView: View {
    let month: Int
    @ObservedObject var viewModel: MainViewModel
    
    private var monthlyExpenses: [CategoryExpense] {
        let transactions = viewModel.transactions.filter {
            Calendar.current.component(.month, from: $0.date) == month &&
            $0.type == .expense
        }
        
        let groupedTransactions = Dictionary(grouping: transactions) { $0.category }
        let totalExpense = transactions.reduce(0) { $0 + $1.amount }
        
        return groupedTransactions.map { category, transactions in
            let amount = transactions.reduce(0) { $0 + $1.amount }
            let percentage = totalExpense > 0 ? (amount / totalExpense) * 100 : 0
            return CategoryExpense(category: category, amount: amount, percentage: percentage)
        }.sorted { $0.amount > $1.amount }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Kategori Detayları")
                .font(.headline)
                .padding(.horizontal)
            
            if monthlyExpenses.isEmpty {
                Text("Bu ay için kategori verisi bulunmuyor")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(monthlyExpenses) { category in
                    VStack(spacing: 8) {
                        HStack {
                            Circle()
                                .fill(categoryColor(for: category.category))
                                .frame(width: 12, height: 12)
                            
                            Text(category.category)
                                .font(.system(.body, design: .rounded))
                            
                            Spacer()
                            
                            Text("₺\(String(format: "%.2f", category.amount))")
                                .font(.system(.callout, design: .rounded, weight: .medium))
                        }
                        
                        GeometryReader { geometry in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(categoryColor(for: category.category).opacity(0.3))
                                .frame(width: geometry.size.width * CGFloat(category.percentage / 100))
                                .frame(height: 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.gray.opacity(0.1))
                                )
                        }
                        .frame(height: 8)
                    }
                    .padding(.horizontal)
                    
                    if category != monthlyExpenses.last {
                        Divider()
                            .padding(.horizontal)
                    }
                }
            }
        }
        .padding(.vertical)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
    
    private func categoryColor(for category: String) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .yellow]
        let index = abs(category.hashValue) % colors.count
        return colors[index]
    }
} 