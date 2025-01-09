import CoreData

@objc(PlannedPaymentEntity)
public class PlannedPaymentEntity: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var amount: Double
    @NSManaged public var dueDate: Date?
    @NSManaged public var note: String?
    @NSManaged public var isRecurring: Bool
    @NSManaged public var recurringInterval: String?
    @NSManaged public var isPaid: Bool
} 