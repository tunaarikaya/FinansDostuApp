import SwiftUI
import Charts

struct GoalDetailView: View {
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss
    let goal: Goal
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var contributionAmount = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Üst Kart
                VStack(spacing: 15) {
                    Text(goal.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        VStack {
                            Text("Hedef")
                            Text("\(goal.targetAmount, specifier: "%.2f") ₺")
                                .fontWeight(.semibold)
                        }
                        
                        Divider()
                            .frame(height: 40)
                        
                        VStack {
                            Text("Biriken")
                            Text("\(goal.savedAmount, specifier: "%.2f") ₺")
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                        
                        Divider()
                            .frame(height: 40)
                        
                        VStack {
                            Text("Kalan")
                            Text("\(goal.targetAmount - goal.savedAmount, specifier: "%.2f") ₺")
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                        }
                    }
                    
                    ProgressView(value: goal.progress)
                        .tint(goal.progress >= 1.0 ? .green : .theme.accent)
                    
                    Text("\(Int(goal.progress * 100))% Tamamlandı")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(radius: 2)
                
                // İstatistikler
                VStack(alignment: .leading, spacing: 15) {
                    Text("İstatistikler")
                        .font(.headline)
                    
                    HStack {
                        StatisticCard(
                            title: "Aylık Gereken",
                            value: goal.requiredMonthlyContribution,
                            color: .orange
                        )
                        
                        StatisticCard(
                            title: "Aylık Ortalama",
                            value: goal.averageMonthlyContribution,
                            color: goal.isOnTrack ? .green : .red
                        )
                    }
                    
                    if !goal.monthlyContributions.isEmpty {
                        Chart {
                            ForEach(Array(goal.monthlyContributions.enumerated()), id: \.offset) { index, contribution in
                                BarMark(
                                    x: .value("Ay", "Ay \(index + 1)"),
                                    y: .value("Katkı", contribution)
                                )
                                .foregroundStyle(Color.theme.accent)
                            }
                        }
                        .frame(height: 200)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(radius: 2)
                
                // Katkı Ekleme
                VStack(spacing: 10) {
                    TextField("Katkı Miktarı", text: $contributionAmount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button {
                        if let amount = Double(contributionAmount) {
                            viewModel.addContribution(to: goal, amount: amount)
                            contributionAmount = ""
                        }
                    } label: {
                        Text("Katkı Ekle")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.theme.accent)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(contributionAmount.isEmpty)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(radius: 2)
                
                // Tasarruf Önerileri
                if let suggestion = viewModel.getSavingSuggestion(for: goal) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Tasarruf Önerisi")
                            .font(.headline)
                        
                        Text(suggestion)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(radius: 2)
                }
            }
            .padding()
        }
        .navigationTitle("Hedef Detayı")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showingEditSheet = true
                    } label: {
                        Label("Düzenle", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Sil", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditGoalView(viewModel: viewModel, goal: goal)
        }
        .alert("Hedefi Sil", isPresented: $showingDeleteAlert) {
            Button("İptal", role: .cancel) { }
            Button("Sil", role: .destructive) {
                viewModel.deleteGoal(goal)
                dismiss()
            }
        } message: {
            Text("Bu hedefi silmek istediğinizden emin misiniz?")
        }
    }
}

struct StatisticCard: View {
    let title: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text("\(value, specifier: "%.2f") ₺")
                .font(.headline)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
} 