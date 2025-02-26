import SwiftUI
import LocalAuthentication
import StoreKit

struct ProfileView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var showingEditProfile = false
    @State private var showingExportAlert = false
    @State private var showingImportPicker = false
    @State private var showingResetAlert = false
    @Environment(\.openURL) private var openURL
    @Environment(\.requestReview) private var requestReview
    @Environment(\.colorScheme) private var colorScheme
    @State private var isImporting = false
    
    private let linkedInURL = URL(string: "https://docs.google.com/document/d/1wqJmpI4E8eVZPuAktAP5CeD7rblXCI8cMglHmJou_78/edit?tab=t.0")
    private let privacyPolicyURL = URL(string: "https://docs.google.com/document/d/195xYCG5C0eRBi7DreOm9zgb_OfnsdgbJh43RY2E5YVA/edit?usp=sharing")
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profil Başlığı
                HStack(spacing: 16) {
                    // Profil Fotosu
                    if let profileImage = viewModel.profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 5)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.blue)
                            .shadow(color: .black.opacity(0.1), radius: 5)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.user.name)
                            .font(.title3.bold())
                        if let email = viewModel.user.email {
                            Text(email)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: { showingEditProfile = true }) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.03), radius: 5)
                .padding(.horizontal)
                
                // Finansal Özet
                VStack(spacing: 20) {
                    Text("Finansal Özet")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    HStack(spacing: 15) {
                        // Gelir Kartı
                        VStack(spacing: 10) {
                            Circle()
                                .fill(Color.green.opacity(0.2))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(.green)
                                )
                            
                            Text("Toplam Gelir")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Text(viewModel.totalIncome.formattedCurrency())
                                .font(.headline)
                                .foregroundStyle(.green)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.05), radius: 5)
                        
                        // Gider Kartı
                        VStack(spacing: 10) {
                            Circle()
                                .fill(Color.red.opacity(0.2))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(systemName: "arrow.down.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(.red)
                                )
                            
                            Text("Toplam Gider")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Text(viewModel.totalExpense.formattedCurrency())
                                .font(.headline)
                                .foregroundStyle(.red)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.05), radius: 5)
                    }
                    .padding(.horizontal)
                    
                    // Net Durum
                    VStack(spacing: 10) {
                        HStack {
                            Text("Net Durum")
                                .font(.headline)
                            Spacer()
                            Text((viewModel.totalIncome - viewModel.totalExpense).formattedCurrency())
                                .font(.title3.bold())
                                .foregroundStyle(viewModel.totalIncome >= viewModel.totalExpense ? .green : .red)
                        }
                        
                        ProgressView(value: min(viewModel.totalIncome / max(viewModel.totalExpense, 1), 1))
                            .tint(viewModel.totalIncome >= viewModel.totalExpense ? .green : .red)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.05), radius: 5)
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.03), radius: 5)
                .padding(.horizontal)
                
                // Ayarlar ve Hakkında
                VStack(spacing: 12) {
                    // Ayarlar
                    VStack(spacing: 15) {
                        HStack {
                            Image(systemName: "gearshape.fill")
                                .font(.title3)
                                .foregroundStyle(.blue)
                            Text("Ayarlar")
                                .font(.headline)
                            Spacer()
                        }
                        
                        Toggle("Karanlık Mod", isOn: $viewModel.isDarkMode)
                            .tint(.blue)
                            .padding()
                        
                        Divider()
                        
                        Button(action: {
                            requestReview()
                        }) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .font(.title3)
                                    .foregroundStyle(.yellow)
                                Text("Bizi Oyla")
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.03), radius: 5)
                    
                    // Hakkında
                    VStack(spacing: 0) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.blue)
                            Text("Hakkında")
                                .font(.headline)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        
                        Divider()
                            .padding(.horizontal)
                        
                        Button(action: { 
                            if let url = linkedInURL {
                                openURL(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "link.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(.blue)
                                Text("Geliştirici ile İletişim")
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.gray)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                        }
                        
                        Divider()
                            .padding(.horizontal)
                        
                        Button(action: { 
                            if let url = privacyPolicyURL {
                                openURL(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                    .font(.title3)
                                    .foregroundStyle(.blue)
                                Text("Gizlilik Sözleşmesi")
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.gray)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                        }
                        
                        Divider()
                            .padding(.horizontal)
                        
                        HStack {
                            Image(systemName: "number.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.blue)
                            Text("Versiyon")
                                .foregroundStyle(.primary)
                            Spacer()
                            Text("1.0.0")
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.03), radius: 5)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            
            Section {
                VStack(spacing: 16) {
                    // Verileri Yedekle Butonu
                    Button(action: { viewModel.exportData() }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                            Text("Verileri Yedekle")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                    }
                    
                    // Yedekten Geri Yükle Butonu
                    Button(action: { showingImportPicker = true }) {
                        HStack {
                            if isImporting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Image(systemName: "square.and.arrow.down")
                                    .foregroundColor(.blue)
                            }
                            Text(isImporting ? "Yükleniyor..." : "Yedekten Geri Yükle")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                    }
                    .disabled(isImporting)
                    
                    // Verileri Sıfırla Butonu
                    Button(action: { showingResetAlert = true }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("Verileri Sıfırla")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Profil")
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(viewModel: viewModel)
        }
        .alert("Verileri Yedekle", isPresented: $showingExportAlert) {
            Button("İptal", role: .cancel) { }
            Button("Yedekle") {
                viewModel.exportData()
            }
        } message: {
            Text("Tüm verileriniz JSON formatında yedeklenecek. Devam etmek istiyor musunuz?")
        }
        .alert("Verileri Sıfırla", isPresented: $showingResetAlert) {
            Button("İptal", role: .cancel) { }
            Button("Sıfırla", role: .destructive) {
                viewModel.resetAllData()
            }
        } message: {
            Text("Tüm verileriniz silinecek. Bu işlem geri alınamaz!")
        }
        .sheet(isPresented: $showingImportPicker) {
            DocumentPicker(completion: { url in
                viewModel.importData(from: url)
            })
        }
        .onReceive(NotificationCenter.default.publisher(for: .userProfileUpdated)) { _ in
            viewModel.objectWillChange.send()
        }
    }
}

// DocumentPicker için yardımcı view
struct DocumentPicker: UIViewControllerRepresentable {
    let completion: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.json])
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        picker.shouldShowFileExtensions = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let completion: (URL) -> Void
        
        init(completion: @escaping (URL) -> Void) {
            self.completion = completion
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            
            guard url.startAccessingSecurityScopedResource() else {
                print("Dosya erişim izni alınamadı")
                return
            }
            
            defer { url.stopAccessingSecurityScopedResource() }
            
            completion(url)
        }
    }
} 
