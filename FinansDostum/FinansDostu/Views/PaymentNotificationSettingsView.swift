import SwiftUI

struct PaymentNotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var preferences: NotificationPreference
    let paymentTitle: String
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Bildirim Zamanları")) {
                    Toggle("Ödeme gününden 1 gün önce", isOn: $preferences.oneDay)
                    Toggle("Ödeme gününden 3 gün önce", isOn: $preferences.threeDays)
                    Toggle("Ödeme gününden 1 hafta önce", isOn: $preferences.oneWeek)
                }
                
                Section(header: Text("Bildirim Önizleme")) {
                    if preferences.oneDay || preferences.threeDays || preferences.oneWeek {
                        VStack(alignment: .leading, spacing: 8) {
                            if preferences.oneWeek {
                                Text("📅 \(paymentTitle) ödemenize 1 hafta kaldı")
                                    .font(.subheadline)
                            }
                            if preferences.threeDays {
                                Text("📅 \(paymentTitle) ödemenize 3 gün kaldı")
                                    .font(.subheadline)
                            }
                            if preferences.oneDay {
                                Text("📅 \(paymentTitle) ödemenize 1 gün kaldı")
                                    .font(.subheadline)
                            }
                        }
                        .padding(.vertical, 8)
                    } else {
                        Text("Bildirim seçilmedi")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Bildirim Ayarları")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Tamam") {
                        dismiss()
                    }
                }
            }
        }
    }
} 