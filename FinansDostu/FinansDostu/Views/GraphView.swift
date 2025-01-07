import SwiftUI
import Charts

struct GraphView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var selectedTimeRange: TimeRange = .month
    @State private var selectedTab = 0
    
    enum TimeRange: String, CaseIterable {
        case week = "Hafta"
        case month = "Ay"
        case year = "Yıl"
    }
    
    // Kategori renkleri
    let categoryColors: [String: Color] = [
        "Market": .blue,
        "Faturalar": .purple,
        "Ulaşım": .orange,
        "Sağlık": .red,
        "Eğlence": .green,
        "Alışveriş": .pink,
        "Maaş": .mint,
        "Ek Gelir": .teal,
        "Diğer": .gray
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Üst Bilgi Kartları
                    HStack(spacing: 15) {
                        InfoCard(
                            title: "Toplam Gelir",
                            amount: viewModel.totalIncome,
                            color: .green,
                            icon: "arrow.up.circle.fill"
                        )
                        
                        InfoCard(
                            title: "Toplam Gider",
                            amount: viewModel.totalExpense,
                            color: .red,
                            icon: "arrow.down.circle.fill"
                        )
                    }
                    .padding(.horizontal)
                    
                    // Grafik Seçici
                    Picker("", selection: $selectedTab) {
                        Text("Dağılım").tag(0)
                        Text("Kategoriler").tag(1)
                        Text("Trend").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    if selectedTab == 0 {
                        // Gelir/Gider Dağılımı
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Gelir/Gider Dağılımı")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            PieChartView(income: viewModel.totalIncome, expense: viewModel.totalExpense)
                                .frame(height: 250)
                                .padding()
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                    } else if selectedTab == 1 {
                        // Kategori Bazlı Harcamalar
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Kategori Bazlı Harcamalar")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            if #available(iOS 16.0, *) {
                                Chart(viewModel.categoryExpenses) { category in
                                    BarMark(
                                        x: .value("Tutar", category.amount),
                                        y: .value("Kategori", category.name)
                                    )
                                    .foregroundStyle(categoryColors[category.name] ?? .gray)
                                }
                                .frame(height: 300)
                                .padding()
                            }
                            
                            // Kategori Listesi
                            ForEach(viewModel.categoryExpenses) { category in
                                HStack {
                                    Circle()
                                        .fill(categoryColors[category.name] ?? .gray)
                                        .frame(width: 10, height: 10)
                                    Text(category.name)
                                    Spacer()
                                    Text(String(format: "%.2f ₺", category.amount))
                                        .fontWeight(.semibold)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 5)
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                    } else {
                        // Aylık Trend
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Aylık Trend")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            if #available(iOS 16.0, *) {
                                Chart(viewModel.monthlyData) { data in
                                    LineMark(
                                        x: .value("Tarih", data.date),
                                        y: .value("Tutar", abs(data.amount))
                                    )
                                    .foregroundStyle(data.isExpense ? .red : .green)
                                    
                                    AreaMark(
                                        x: .value("Tarih", data.date),
                                        y: .value("Tutar", abs(data.amount))
                                    )
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                data.isExpense ? .red.opacity(0.3) : .green.opacity(0.3),
                                                data.isExpense ? .red.opacity(0.1) : .green.opacity(0.1)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    
                                    PointMark(
                                        x: .value("Tarih", data.date),
                                        y: .value("Tutar", abs(data.amount))
                                    )
                                    .foregroundStyle(data.isExpense ? .red : .green)
                                }
                                .frame(height: 250)
                                .padding()
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                    }
                    
                    // İstatistik Kartları
                    VStack(spacing: 15) {
                        StatCard(
                            title: "En Yüksek Gider",
                            value: viewModel.highestExpense.amount,
                            subtitle: viewModel.highestExpense.title,
                            color: .red
                        )
                        
                        StatCard(
                            title: "Ortalama Gider",
                            value: viewModel.averageExpense,
                            subtitle: "Aylık",
                            color: .orange
                        )
                    }
                    .padding()
                }
            }
            .navigationTitle("Grafikler")
        }
    }
}

struct InfoCard: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(String(format: "%.2f ₺", amount))
                .font(.title3.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(radius: 5)
        )
    }
}

struct StatCard: View {
    let title: String
    let value: Double
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(String(format: "%.2f ₺", value))
                    .font(.title3.bold())
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(color)
                )
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

// Yardımcı görünümler
struct PieChartView: View {
    let income: Double
    let expense: Double
    
    var body: some View {
        GeometryReader { geometry in
            let radius = min(geometry.size.width, geometry.size.height) / 2
            ZStack {
                Circle()
                    .trim(from: 0, to: income / (income + expense))
                    .stroke(Color.theme.green, lineWidth: 30)
                    .rotationEffect(.degrees(-90))
                
                Circle()
                    .trim(from: 0, to: expense / (income + expense))
                    .stroke(Color.theme.red, lineWidth: 30)
                    .rotationEffect(.degrees(-90 + 360 * (income / (income + expense))))
                
                VStack {
                    Text("Toplam")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.2f ₺", income - expense))
                        .font(.title2.bold())
                }
            }
            .frame(width: radius * 2, height: radius * 2)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
} 