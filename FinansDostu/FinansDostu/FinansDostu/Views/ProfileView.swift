import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var showingEditProfile = false
    
    var body: some View {
        List {
            Section {
                HStack {
                    VStack(alignment: .leading) {
                        Text(viewModel.user.name)
                            .font(.headline)
                        if let email = viewModel.user.email {
                            Text(email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    Button(action: { showingEditProfile = true }) {
                        Image(systemName: "pencil.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Section(header: Text("Finansal Özet")) {
                HStack {
                    Text("Toplam Gelir")
                    Spacer()
                    Text(String(format: "%.2f ₺", viewModel.totalIncome))
                        .foregroundColor(.green)
                }
                
                HStack {
                    Text("Toplam Gider")
                    Spacer()
                    Text(String(format: "%.2f ₺", viewModel.totalExpense))
                        .foregroundColor(.red)
                }
                
                HStack {
                    Text("Net Durum")
                    Spacer()
                    Text(String(format: "%.2f ₺", viewModel.totalIncome - viewModel.totalExpense))
                        .foregroundColor(viewModel.totalIncome >= viewModel.totalExpense ? .green : .red)
                }
            }
            
            Section(header: Text("Ayarlar")) {
                Toggle("Karanlık Mod", isOn: $viewModel.isDarkMode)
                Toggle("Bildirimler", isOn: .constant(viewModel.user.notificationsEnabled))
            }
        }
        .navigationTitle("Profil")
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(viewModel: viewModel)
        }
    }
} 