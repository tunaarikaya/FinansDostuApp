import SwiftUI

struct GoalsView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var showingAddGoal = false
    @State private var selectedCategory: GoalCategory? = nil
    @State private var showingDeleteAlert = false
    @State private var goalToDelete: Goal? = nil
    
    private var filteredGoals: [Goal] {
        guard let category = selectedCategory else { return viewModel.goals }
        return viewModel.goals.filter { $0.category == category }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Kategori Filtreleme
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            CategoryFilterButton(title: "Tümü", isSelected: selectedCategory == nil) {
                                selectedCategory = nil
                            }
                            
                            ForEach(GoalCategory.allCases, id: \.self) { category in
                                CategoryFilterButton(
                                    title: category.rawValue,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Toplam İlerleme
                    if !viewModel.goals.isEmpty {
                        VStack(spacing: 15) {
                            Text("Toplam Hedef Durumu")
                                .font(.headline)
                            
                            HStack(spacing: 30) {
                                VStack {
                                    Text("Toplam Hedef")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(String(format: "%.2f ₺", viewModel.totalGoalAmount))
                                        .font(.title3)
                                        .fontWeight(.bold)
                                }
                                
                                VStack {
                                    Text("Toplam Birikim")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(String(format: "%.2f ₺", viewModel.totalSavedAmount))
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                }
                            }
                            
                            ProgressView(value: viewModel.totalProgress)
                                .tint(.theme.accent)
                                .padding(.horizontal)
                            
                            Text("\(Int(viewModel.totalProgress * 100))% Tamamlandı")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(radius: 2)
                        .padding(.horizontal)
                    }
                    
                    // Hedefler Listesi
                    LazyVStack(spacing: 15) {
                        ForEach(filteredGoals) { goal in
                            GoalCard(goal: goal)
                                .onTapGesture {
                                    // Detay sayfasına git
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        goalToDelete = goal
                                        showingDeleteAlert = true
                                    } label: {
                                        Label("Sil", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                    
                    if viewModel.goals.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "target")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("Henüz hedef eklemediniz")
                                .font(.headline)
                            Text("Yeni bir hedef eklemek için + butonuna tıklayın")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 50)
                    }
                }
            }
            .navigationTitle("Hedeflerim")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddGoal.toggle()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.theme.accent)
                    }
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView(viewModel: viewModel)
            }
            .alert("Hedefi Sil", isPresented: $showingDeleteAlert) {
                Button("İptal", role: .cancel) { }
                Button("Sil", role: .destructive) {
                    if let goal = goalToDelete {
                        withAnimation {
                            viewModel.deleteGoal(goal)
                        }
                    }
                }
            } message: {
                if let goal = goalToDelete {
                    Text("\(goal.title) hedefini silmek istediğinizden emin misiniz?")
                }
            }
        }
    }
}

struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(isSelected ? Color.theme.accent : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct GoalCard: View {
    let goal: Goal
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.headline)
                    Text(goal.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(goal.remainingDays)
                    .font(.caption)
                    .padding(6)
                    .background(goal.isUrgent ? Color.red.opacity(0.1) : Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                    .foregroundColor(goal.isUrgent ? .red : .secondary)
            }
            
            HStack {
                Text(String(format: "%.2f ₺", goal.savedAmount))
                    .foregroundColor(.green)
                Text("/")
                Text(String(format: "%.2f ₺", goal.targetAmount))
                    .foregroundColor(.secondary)
            }
            .font(.subheadline)
            
            ProgressView(value: goal.progress)
                .tint(goal.progress >= 1.0 ? .green : .theme.accent)
            
            HStack {
                Text("\(Int(goal.progress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !goal.isOnTrack {
                    Label("Hedefe ulaşmak için hız kazanın", systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}


