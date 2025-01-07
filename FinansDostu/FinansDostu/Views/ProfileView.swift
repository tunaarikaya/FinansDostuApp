import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var showingEditProfile = false
    @State private var notificationsEnabled = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profil Başlığı
                    VStack(spacing: 15) {
                        if let imageData = viewModel.user.profileImageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.theme.accent)
                        }
                        
                        VStack(spacing: 4) {
                            Text(viewModel.user.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            if let email = viewModel.user.email {
                                Text(email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Button {
                            showingEditProfile.toggle()
                        } label: {
                            Text("Profili Düzenle")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color.theme.accent)
                                .cornerRadius(20)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(radius: 2)
                    
                    // Finansal Özet
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Finansal Özet")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 15) {
                            FinancialSummaryRow(
                                title: "Toplam Gelir",
                                amount: viewModel.totalIncome,
                                color: .green
                            )
                            
                            FinancialSummaryRow(
                                title: "Toplam Gider",
                                amount: viewModel.totalExpense,
                                color: .red
                            )
                            
                            Divider()
                            
                            FinancialSummaryRow(
                                title: "Net Durum",
                                amount: viewModel.user.balance,
                                color: viewModel.user.balance >= 0 ? .green : .red
                            )
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(radius: 2)
                    }
                    
                    // İstatistikler
                    VStack(alignment: .leading, spacing: 15) {
                        Text("İstatistikler")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack(spacing: 15) {
                            StatisticBox(
                                title: "En Yüksek Gider",
                                value: viewModel.highestExpense.amount,
                                subtitle: viewModel.highestExpense.title
                            )
                            
                            StatisticBox(
                                title: "Ortalama Gider",
                                value: viewModel.averageExpense,
                                subtitle: "Aylık"
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Ayarlar
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Ayarlar")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            // Karanlık Mod
                            HStack {
                                Image(systemName: "moon.fill")
                                    .foregroundColor(.theme.accent)
                                    .frame(width: 30)
                                Text("Karanlık Mod")
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get: { viewModel.isDarkMode },
                                    set: { newValue in
                                        viewModel.isDarkMode = newValue
                                    }
                                ))
                            }
                            .padding()
                            
                            Divider()
                                .padding(.leading, 50)
                            
                            // Bildirimler
                            NavigationLink {
                                NotificationsSettingsView(isEnabled: $notificationsEnabled)
                            } label: {
                                HStack {
                                    Image(systemName: "bell.fill")
                                        .foregroundColor(.theme.accent)
                                        .frame(width: 30)
                                    Text("Bildirimler")
                                    Spacer()
                                }
                                .padding()
                            }
                            
                            Divider()
                                .padding(.leading, 50)
                            
                            // Para Birimi
                            NavigationLink {
                                CurrencySettingsView()
                            } label: {
                                HStack {
                                    Image(systemName: "turkishlirasign.circle.fill")
                                        .foregroundColor(.theme.accent)
                                        .frame(width: 30)
                                    Text("Para Birimi")
                                    Spacer()
                                    Text(viewModel.user.currency)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            }
                            
                            Divider()
                                .padding(.leading, 50)
                            
                            // Dil
                            NavigationLink {
                                LanguageSettingsView()
                            } label: {
                                HStack {
                                    Image(systemName: "globe")
                                        .foregroundColor(.theme.accent)
                                        .frame(width: 30)
                                    Text("Dil")
                                    Spacer()
                                    Text(viewModel.user.language)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            }
                            
                            Divider()
                                .padding(.leading, 50)
                            
                            // Gizlilik
                            NavigationLink {
                                PrivacySettingsView()
                            } label: {
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.theme.accent)
                                        .frame(width: 30)
                                    Text("Gizlilik")
                                    Spacer()
                                }
                                .padding()
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(radius: 2)
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
            .navigationTitle("Profil")
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(viewModel: viewModel)
            }
        }
    }
}

struct FinancialSummaryRow: View {
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(String(format: "%.2f ₺", amount))
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

struct StatisticBox: View {
    let title: String
    let value: Double
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(String(format: "%.2f ₺", value))
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct NotificationsSettingsView: View {
    @Binding var isEnabled: Bool
    
    var body: some View {
        Form {
            Section {
                Toggle("Bildirimleri Etkinleştir", isOn: $isEnabled)
                
                if isEnabled {
                    Toggle("Ödeme Hatırlatıcıları", isOn: .constant(true))
                    Toggle("Hedef Bildirimleri", isOn: .constant(true))
                    Toggle("Bütçe Uyarıları", isOn: .constant(true))
                }
            }
            
            Section {
                Text("Bildirimler, önemli finansal olayları ve hatırlatıcıları takip etmenize yardımcı olur.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Bildirimler")
    }
}

struct CurrencySettingsView: View {
    var body: some View {
        List {
            Text("₺ Türk Lirası")
            Text("$ Amerikan Doları")
            Text("€ Euro")
            Text("£ İngiliz Sterlini")
        }
        .navigationTitle("Para Birimi")
    }
}

struct LanguageSettingsView: View {
    var body: some View {
        List {
            Text("Türkçe")
            Text("English")
        }
        .navigationTitle("Dil")
    }
}

struct PrivacySettingsView: View {
    var body: some View {
        Form {
            Section(header: Text("Güvenlik")) {
                Toggle("Face ID ile Giriş", isOn: .constant(false))
                Toggle("Otomatik Kilit", isOn: .constant(true))
            }
            
            Section(header: Text("Veri Gizliliği")) {
                Toggle("Analitik Verileri Paylaş", isOn: .constant(false))
                Toggle("Çökme Raporları Gönder", isOn: .constant(true))
            }
        }
        .navigationTitle("Gizlilik")
    }
} 