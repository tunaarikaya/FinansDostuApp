import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var showingAddPayment = false
    @State private var showingDailyPayments = false
    @State private var selectedDate = Date()
    
    private let calendar = Calendar.current
    private let months = [
        "Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran",
        "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Ay Seçici
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(1...12, id: \.self) { month in
                            PaymentMonthButton(
                                monthName: months[month - 1],
                                isSelected: selectedMonth == month,
                                totalAmount: totalAmountForMonth(month),
                                completedAmount: completedAmountForMonth(month)
                            ) {
                                selectedMonth = month
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // Aylık Özet
                VStack(spacing: 16) {
                    HStack {
                        Text(months[selectedMonth - 1])
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                        Spacer()
                        Text(totalAmountForMonth(selectedMonth).formattedCurrency())
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // İlerleme Çubuğu
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue)
                                .frame(width: progressWidth(for: selectedMonth, totalWidth: geometry.size.width), height: 8)
                        }
                    }
                    .frame(height: 8)
                    .padding(.horizontal)
                    
                    HStack {
                        Text("Ödenen: \(completedAmountForMonth(selectedMonth).formattedCurrency())")
                            .foregroundColor(.green)
                        Spacer()
                        Text("Kalan: \(remainingAmountForMonth(selectedMonth).formattedCurrency())")
                            .foregroundColor(.red)
                    }
                    .font(.subheadline)
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                
                // Planlı Ödemeler Listesi
                VStack(alignment: .leading, spacing: 16) {
                    Text("Planlı Ödemeler")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if paymentsForMonth(selectedMonth).isEmpty {
                        Text("Bu ay için planlı ödeme bulunmuyor")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        ForEach(paymentsForMonth(selectedMonth)) { payment in
                            PaymentRowView(payment: payment, onUpdate: { updatedPayment in
                                viewModel.updatePlannedPayment(updatedPayment)
                            }, viewModel: viewModel)
                            
                            if payment.id != paymentsForMonth(selectedMonth).last?.id {
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
        }
        .navigationTitle("Ödemeler")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { showingDailyPayments = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.title3)
                        Text("Günlük Sorgula")
                            .font(.headline)
                    }
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(20)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddPayment = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        Text("Ödeme Ekle")
                            .font(.headline)
                    }
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(20)
                }
            }
        }
        .sheet(isPresented: $showingAddPayment) {
            AddPlannedPaymentView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingDailyPayments) {
            DailyPaymentsView(viewModel: viewModel, selectedDate: $selectedDate)
        }
    }
    
    private func paymentsForMonth(_ month: Int) -> [PlannedPayment] {
        viewModel.plannedPayments.filter { payment in
            calendar.component(.month, from: payment.dueDate) == month
        }.sorted { $0.dueDate < $1.dueDate }
    }
    
    private func totalAmountForMonth(_ month: Int) -> Double {
        let total = paymentsForMonth(month).reduce(0) { $0 + $1.amount }
        return total.isNaN ? 0 : total
    }
    
    private func completedAmountForMonth(_ month: Int) -> Double {
        let completed = paymentsForMonth(month).filter { $0.isPaid }.reduce(0) { $0 + $1.amount }
        return completed.isNaN ? 0 : completed
    }
    
    private func remainingAmountForMonth(_ month: Int) -> Double {
        let remaining = totalAmountForMonth(month) - completedAmountForMonth(month)
        return remaining.isNaN ? 0 : max(0, remaining)
    }
    
    private func progressWidth(for month: Int, totalWidth: CGFloat) -> CGFloat {
        let total = totalAmountForMonth(month)
        let completed = completedAmountForMonth(month)
        
        guard total > 0, !total.isNaN, !completed.isNaN else { return 0 }
        
        let progress = completed / total
        guard !progress.isNaN else { return 0 }
        
        // Progress değerini 0 ile 1 arasında sınırla
        let clampedProgress = min(1, max(0, progress))
        
        return totalWidth * clampedProgress
    }
}

struct PaymentMonthButton: View {
    let monthName: String
    let isSelected: Bool
    let totalAmount: Double
    let completedAmount: Double
    let action: () -> Void
    
    private var progress: Double {
        totalAmount > 0 ? (completedAmount / totalAmount) : 0
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(monthName)
                    .font(.system(.callout, design: .rounded))
                    .fontWeight(isSelected ? .bold : .medium)
                    .foregroundStyle(isSelected ? .white : .primary)
                
                Text(String(format: "%.0f%%", progress * 100))
                    .font(.caption2)
                    .foregroundStyle(isSelected ? .white.opacity(0.9) : .secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct DailyPaymentsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MainViewModel
    @Binding var selectedDate: Date
    
    private var paymentsForSelectedDate: [PlannedPayment] {
        viewModel.plannedPayments.filter { payment in
            Calendar.current.isDate(payment.dueDate, inSameDayAs: selectedDate)
        }.sorted { $0.dueDate < $1.dueDate }
    }
    
    private var totalAmount: Double {
        paymentsForSelectedDate.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Takvim için minimum yükseklik tanımlıyoruz
                    DatePicker("Tarih Seçin", selection: $selectedDate, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .padding()
                        .frame(minHeight: 380) // UICalendarView için minimum yükseklik
                    
                    LazyVStack(alignment: .leading, spacing: 16) {
                        Text("Seçilen Tarih: \(selectedDate.formatted(date: .long, time: .omitted))")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if paymentsForSelectedDate.isEmpty {
                            Text("Bu tarihte planlı ödeme bulunmuyor")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Ödemeler")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                LazyVStack(spacing: 0) {
                                    ForEach(paymentsForSelectedDate) { payment in
                                        PaymentRowView(payment: payment, onUpdate: { updatedPayment in
                                            viewModel.updatePlannedPayment(updatedPayment)
                                        }, viewModel: viewModel)
                                        .padding(.horizontal)
                                        
                                        if payment.id != paymentsForSelectedDate.last?.id {
                                            Divider()
                                                .padding(.horizontal)
                                        }
                                    }
                                }
                                
                                Divider()
                                    .padding(.horizontal)
                                
                                HStack {
                                    Text("Toplam Tutar:")
                                        .font(.headline)
                                    Spacer()
                                    Text(totalAmount.formattedCurrency())
                                        .font(.headline)
                                        .foregroundStyle(.blue)
                                }
                                .padding(.horizontal)
                            }
                            .padding(.vertical)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle("Günlük Ödemeler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }
}
