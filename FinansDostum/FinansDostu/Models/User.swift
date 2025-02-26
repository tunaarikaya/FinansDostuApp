import Foundation

struct User: Identifiable {
    let id: UUID
    var name: String
    var email: String?
    var balance: Double
    var prefersDarkMode: Bool
    var profileImageData: Data?
    
    init(id: UUID = UUID(),
         name: String,
         email: String? = nil,
         balance: Double = 0,
         prefersDarkMode: Bool = false,
         profileImageData: Data? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.balance = balance
        self.prefersDarkMode = prefersDarkMode
        self.profileImageData = profileImageData
    }
} 