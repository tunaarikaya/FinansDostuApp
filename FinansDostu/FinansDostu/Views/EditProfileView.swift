import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MainViewModel
    
    @State private var name: String
    @State private var email: String
    @State private var selectedItem: PhotosPickerItem?
    @State private var profileImage: Image?
    @State private var profileImageData: Data?
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        _name = State(initialValue: viewModel.user.name)
        _email = State(initialValue: viewModel.user.email ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profil Fotoğrafı")) {
                    VStack {
                        if let profileImage {
                            profileImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else if let imageData = viewModel.user.profileImageData,
                                 let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 100))
                                .foregroundColor(.theme.accent)
                        }
                        
                        PhotosPicker(selection: $selectedItem,
                                   matching: .images) {
                            Text("Fotoğraf Seç")
                                .foregroundColor(.theme.accent)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                }
                
                Section(header: Text("Kişisel Bilgiler")) {
                    TextField("İsim", text: $name)
                    TextField("E-posta", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                
                Section(header: Text("Hesap")) {
                    Button(role: .destructive) {
                        // Hesap silme işlemi
                    } label: {
                        HStack {
                            Spacer()
                            Text("Hesabı Sil")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Profili Düzenle")
            .navigationBarItems(
                leading: Button("İptal") { dismiss() },
                trailing: Button("Kaydet") {
                    viewModel.updateUserProfile(
                        name: name,
                        email: email.isEmpty ? nil : email,
                        profileImageData: profileImageData ?? viewModel.user.profileImageData
                    )
                    dismiss()
                }
                .disabled(name.isEmpty)
            )
        }
        .onChange(of: selectedItem) { _ in
            Task {
                if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        profileImage = Image(uiImage: uiImage)
                        profileImageData = data // Seçilen fotoğrafın verisini saklıyoruz
                    }
                }
            }
        }
    }
} 