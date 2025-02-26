import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var showingAddTransaction = false
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var expandedSection: ExpandedSection? = nil
    @State private var selectedTransaction: Transaction?
    @State private var showingTransactionDetails = false
    @State private var showingDeleteAlert = false
    @Environment(\.dismiss) private var dismiss
    @State private var transactionToDelete: Transaction?
    @State private var showingAddPlannedPaymentSheet = false
    @State private var showingSettingsSheet = false
    
    enum ExpandedSection {
        case recentTransactions
        case plannedPayments
        case budgetAssistant
    }
    
    var filteredTransactions: [Transaction] {
        if searchText.isEmpty {
            return viewModel.transactions
        } else {
            return viewModel.transactions.filter { transaction in
                transaction.title.localizedCaseInsensitiveContains(searchText) ||
                transaction.category.localizedCaseInsensitiveContains(searchText) ||
                String(format: "%.2f", transaction.amount).contains(searchText)
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 16) {
                    // Profil ve isim - üstte uygun boşlukla
                    UserHeaderView(user: viewModel.user)
                        .padding(.top, 12)
                    
                    // Bakiye kartı - yeterli boşlukla
                    BalanceCardView(balance: viewModel.user.balance)
                        .padding(.top, 5)
                    
                    // Vadesi geçmiş ödemeler uyarısı
                    if !viewModel.overduePayments.isEmpty {
                        OverduePaymentsAlert(payments: viewModel.overduePayments, viewModel: viewModel)
                            .padding(.top, 5)
                    }
                    
                    // Son İşlemler başlığı
                    HStack {
                        Text("Son İşlemler")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Arama butonu
                        Button(action: {
                            isSearching = true
                        }) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 0)
                    .padding(.top, 5)
                    
                    // Arama çubuğu (sadece arama modundayken)
                    if isSearching {
                        SearchBar(text: $searchText, isSearching: $isSearching)
                            .padding(.horizontal, 0)
                    }
                    
                    // Son İşlemler Listesi - genişletilmiş görünüm
                    RecentTransactionsView(
                        transactions: filteredTransactions,
                        viewModel: viewModel,
                        selectedTransaction: $selectedTransaction,
                        showingTransactionDetails: $showingTransactionDetails
                    )
                    .padding(.horizontal, 0)  // Padding kaldırıldı
                }
                .padding(.horizontal, 8)  // Ana içerik için minimum padding
                .padding(.bottom, 16)
            }
            
            // İşlem Ekleme Butonu
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showingAddTransaction = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(.blue)
                            .background(Circle().fill(.white))
                            .shadow(color: .black.opacity(0.2), radius: 5)
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, 16)
                }
            }
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingTransactionDetails) {
            if let transaction = selectedTransaction {
                NavigationView {
                    List {
                        Section {
                            HStack {
                                Text("Tutar")
                                Spacer()
                                Text(transaction.amount.formattedCurrency())
                                    .foregroundStyle(transaction.type == .expense ? .red : .green)
                            }
                            
                            HStack {
                                Text("Kategori")
                                Spacer()
                                Text(transaction.category)
                                    .foregroundStyle(.secondary)
                            }
                            
                            HStack {
                                Text("Tarih")
                                Spacer()
                                Text(transaction.date.formatted(date: .long, time: .omitted))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        if let note = transaction.note, !note.isEmpty {
                            Section(header: Text("Notunuz")) {
                                Text(note)
                                    .foregroundStyle(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 8)
                            }
                        }
                        
                        Section {
                            Button(role: .destructive) {
                                showingDeleteAlert = true
                            } label: {
                                HStack {
                                    Image(systemName: "trash.fill")
                                    Text("İşlemi Sil")
                                }
                            }
                        }
                    }
                    .navigationTitle(transaction.title)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Kapat") {
                                showingTransactionDetails = false
                            }
                        }
                    }
                    .alert("İşlemi Sil", isPresented: $showingDeleteAlert) {
                        Button("İptal", role: .cancel) { }
                        Button("Sil", role: .destructive) {
                            viewModel.deleteTransaction(transaction)
                            showingTransactionDetails = false
                        }
                    } message: {
                        Text("Bu işlemi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.")
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct UserHeaderView: View {
    let user: User
    
    var body: some View {
        HStack(spacing: 15) {
            if let imageData = user.profileImageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 54, height: 54)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 54))
                    .foregroundStyle(.blue)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(user.name)
                    .font(.title3.bold())
                Text("Hoş Geldiniz")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 4)
    }
}

struct SearchBar: View {
    @Binding var text: String
    @Binding var isSearching: Bool
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                
                TextField("İşlem Ara...", text: $text)
                    .textFieldStyle(.plain)
                
                if !text.isEmpty {
                    Button(action: { text = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}

struct SearchResultsView: View {
    let transactions: [Transaction]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Arama Sonuçları")
                .font(.headline)
                .padding(.horizontal)
            
            if transactions.isEmpty {
                Text("Sonuç bulunamadı")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(transactions) { transaction in
                    TransactionRowView(transaction: transaction,viewModel:MainViewModel())
                    
                    if transaction.id != transactions.last?.id {
                        Divider()
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct ExpandableSection<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    let isExpanded: Bool
    let onTap: () -> Void
    let content: () -> Content
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HStack {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(iconColor)
                    
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.gray)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding()
            }
            
            if isExpanded {
                content()
                    .padding(.top, 8)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .animation(.spring(), value: isExpanded)
    }
}

// Vadesi geçmiş ödemeler için uyarı bileşeni
struct OverduePaymentsAlert: View {
    let payments: [PlannedPayment]
    @ObservedObject var viewModel: MainViewModel
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                isExpanded.toggle()
            }) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                    
                    Text("Vadesi Geçmiş Ödemeler (\(payments.count))")
                        .font(.headline)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
            
            if isExpanded {
                Divider()
                
                ForEach(payments.prefix(3)) { payment in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(payment.title)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text("Vade Tarihi: \(payment.dueDate.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(payment.amount.formattedCurrency())
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                    .padding(.vertical, 4)
                    
                    HStack {
                        Spacer()
                        
                        if payment.isPaid {
                            Button(action: {
                                viewModel.unmarkPaymentAsCompleted(payment)
                            }) {
                                Text("Ödeme İşaretini Kaldır")
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        } else {
                            Button(action: {
                                viewModel.markPaymentAsCompleted(payment)
                            }) {
                                Text("Ödendi Olarak İşaretle")
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    
                    if payment.id != payments.prefix(3).last?.id {
                        Divider()
                    }
                }
                
                if payments.count > 3 {
                    NavigationLink(destination: AllOverduePaymentsView(payments: payments, viewModel: viewModel)) {
                        Text("Tümünü Görüntüle (\(payments.count))")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// Tüm vadesi geçmiş ödemeleri gösteren görünüm
struct AllOverduePaymentsView: View {
    let payments: [PlannedPayment]
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        List {
            ForEach(payments) { payment in
                VStack(alignment: .leading, spacing: 8) {
                    Text(payment.title)
                        .font(.headline)
                    
                    Text("Vade Tarihi: \(payment.dueDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text(payment.amount.formattedCurrency())
                            .font(.subheadline)
                            .foregroundColor(payment.isPaid ? .green : .red)
                        
                        Spacer()
                        
                        if payment.isPaid {
                            Button(action: {
                                viewModel.unmarkPaymentAsCompleted(payment)
                            }) {
                                Text("Ödeme İşaretini Kaldır")
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        } else {
                            Button(action: {
                                viewModel.markPaymentAsCompleted(payment)
                            }) {
                                Text("Ödendi Olarak İşaretle")
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Vadesi Geçmiş Ödemeler")
    }
}
