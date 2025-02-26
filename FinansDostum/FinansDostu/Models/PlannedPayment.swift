import Foundation

struct NotificationPreference: Codable, Hashable {
    var oneDay: Bool = false
    var threeDays: Bool = false
    var oneWeek: Bool = false
}

struct PlannedPayment: Identifiable, Codable {
    var id: UUID
    var title: String
    var amount: Double
    var dueDate: Date
    var isPaid: Bool
    var note: String?
    var notificationPreferences: NotificationPreference
    var isRecurring: Bool
    var recurringInterval: String?
} 
