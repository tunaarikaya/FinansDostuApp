import Foundation
import CoreData

@objc(TransactionEntity)
public class TransactionEntity: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID?
    @NSManaged public var amount: Double
    @NSManaged public var title: String?
    @NSManaged public var type: String?
    @NSManaged public var date: Date?
    @NSManaged public var category: String?
    @NSManaged public var note: String?
} 