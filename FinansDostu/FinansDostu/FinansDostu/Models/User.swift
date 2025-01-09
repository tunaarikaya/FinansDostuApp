import Foundation

struct User: Identifiable {
    let id: UUID
    var name: String
    var email: String?
    var balance: Double
    var prefersDarkMode: Bool
    var notificationsEnabled: Bool
    var profileImageData: Data?
    var currency: String = "₺" // Varsayılan para birimi
    
    init(id: UUID = UUID(),
         name: String,
         email: String? = nil,
         balance: Double = 0,
         prefersDarkMode: Bool = false,
         notificationsEnabled: Bool = true,
         profileImageData: Data? = nil,
         currency: String = "₺") {
        self.id = id
        self.name = name
        self.email = email
        self.balance = balance
        self.prefersDarkMode = prefersDarkMode
        self.notificationsEnabled = notificationsEnabled
        self.profileImageData = profileImageData
        self.currency = currency
    }
} 