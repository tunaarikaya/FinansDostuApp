import Foundation

struct User: Identifiable {
    let id: UUID
    var name: String
    var balance: Double
    var email: String?
    var profileImageData: Data?
    var prefersDarkMode: Bool
    var notificationsEnabled: Bool
    var currency: String
    var language: String
    
    init(id: UUID = UUID(), 
         name: String, 
         balance: Double = 0, 
         email: String? = nil,
         profileImageData: Data? = nil,
         prefersDarkMode: Bool = false,
         notificationsEnabled: Bool = true,
         currency: String = "₺",
         language: String = "TR") {
        self.id = id
        self.name = name
        self.balance = balance
        self.email = email
        self.profileImageData = profileImageData
        self.prefersDarkMode = prefersDarkMode
        self.notificationsEnabled = notificationsEnabled
        self.currency = currency
        self.language = language
    }
} 