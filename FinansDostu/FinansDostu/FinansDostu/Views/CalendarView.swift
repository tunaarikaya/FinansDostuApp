import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var showingAddPayment = false
    
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
                        Spacer()
                        Text("Toplam: \(String(format: "%.2f ₺", totalAmountForMonth(selectedMonth)))")
                            .font(.headline)
                            .foregroundStyle(.secondary)
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
                        Text("Ödenen: \(String(format: "%.2f ₺", completedAmountForMonth(selectedMonth)))")
                            .foregroundStyle(.green)
                        Spacer()
                        Text("Kalan: \(String(format: "%.2f ₺", remainingAmountForMonth(selectedMonth)))")
                            .foregroundStyle(.red)
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
                            PaymentRowView(payment: payment) { updatedPayment in
                                viewModel.updatePlannedPayment(updatedPayment)
                            }
                            
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
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddPayment = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.blue)
                }
            }
        }
        .sheet(isPresented: $showingAddPayment) {
            AddPlannedPaymentView(viewModel: viewModel)
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
        
        return min(totalWidth, max(0, totalWidth * progress))
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

struct PaymentRowView: View {
    let payment: PlannedPayment
    let onUpdate: (PlannedPayment) -> Void
    
    var body: some View {
        HStack {
            // Ödeme Durumu Göstergesi
            Button(action: {
                var updatedPayment = payment
                updatedPayment.isPaid.toggle()
                onUpdate(updatedPayment)
            }) {
                Image(systemName: payment.isPaid ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(payment.isPaid ? .green : .gray)
            }
            .buttonStyle(.plain)
            
            // Ödeme Bilgileri
            VStack(alignment: .leading, spacing: 4) {
                Text(payment.title)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(payment.isPaid ? .secondary : .primary)
                
                HStack {
                    Text(payment.dueDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if payment.isRecurring {
                        Text("Tekrarlayan")
                            .font(.caption)
                            .foregroundStyle(.blue)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
            }
            
            Spacer()
            
            // Tutar
            Text(String(format: "%.2f ₺", payment.amount))
                .font(.system(.callout, design: .rounded, weight: .medium))
                .foregroundStyle(payment.isPaid ? .green : .primary)
        }
        .padding(.horizontal)
        .contentShape(Rectangle())
    }
}
