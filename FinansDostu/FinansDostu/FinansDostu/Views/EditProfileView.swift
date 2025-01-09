import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MainViewModel
    
    @State private var name: String
    @State private var email: String
    @State private var isDarkMode: Bool
    @State private var notificationsEnabled: Bool
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        _name = State(initialValue: viewModel.user.name)
        _email = State(initialValue: viewModel.user.email ?? "")
        _isDarkMode = State(initialValue: viewModel.isDarkMode)
        _notificationsEnabled = State(initialValue: viewModel.user.notificationsEnabled)
    }
    
    var body: some View {
        NavigationView {
            Form {
                profileSection
                appearanceSection
                notificationSection
            }
            .navigationTitle("Profili Düzenle")
            .toolbar {
                toolbarItems
            }
        }
    }
    
    private var profileSection: some View {
        Section(header: Text("Profil Bilgileri")) {
            TextField("Ad Soyad", text: $name)
            TextField("E-posta", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
        }
    }
    
    private var appearanceSection: some View {
        Section(header: Text("Görünüm")) {
            Toggle("Karanlık Mod", isOn: $isDarkMode)
        }
    }
    
    private var notificationSection: some View {
        Section(header: Text("Bildirimler")) {
            Toggle("Bildirimleri Etkinleştir", isOn: $notificationsEnabled)
        }
    }
    
    private var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("İptal") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Kaydet") {
                    saveChanges()
                    dismiss()
                }
            }
        }
    }
    
    private func saveChanges() {
        viewModel.updateUserProfile(
            name: name,
            email: email.isEmpty ? nil : email,
            notificationsEnabled: notificationsEnabled
        )
        viewModel.isDarkMode = isDarkMode
    }
} 