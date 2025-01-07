import CoreData

@objc(GoalEntity)
public class GoalEntity: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var targetAmount: Double
    @NSManaged public var savedAmount: Double
    @NSManaged public var dueDate: Date?
    @NSManaged public var note: String?
    @NSManaged public var category: String?
    @NSManaged public var monthlyContributions: Data?
    @NSManaged public var lastUpdateDate: Date?
} 