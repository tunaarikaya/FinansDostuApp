import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer

    // Yardımcı fonksiyonlar
    private static func createAttribute(_ name: String, _ type: NSAttributeType) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        attribute.isOptional = false
        return attribute
    }
    
    private static func createOptionalAttribute(_ name: String, _ type: NSAttributeType) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        attribute.isOptional = true
        return attribute
    }

    init(inMemory: Bool = false) {
        // Model tanımlaması
        let model = NSManagedObjectModel()
        
        // TransactionEntity
        let transactionEntity = NSEntityDescription()
        transactionEntity.name = "TransactionEntity"
        transactionEntity.managedObjectClassName = "TransactionEntity"
        
        let transactionAttributes: [String: NSAttributeDescription] = [
            "id": Self.createAttribute("id", .UUIDAttributeType),
            "amount": Self.createAttribute("amount", .doubleAttributeType),
            "title": Self.createAttribute("title", .stringAttributeType),
            "type": Self.createAttribute("type", .stringAttributeType),
            "date": Self.createAttribute("date", .dateAttributeType),
            "category": Self.createAttribute("category", .stringAttributeType)
        ]
        transactionEntity.properties = Array(transactionAttributes.values)
        
        // GoalEntity
        let goalEntity = NSEntityDescription()
        goalEntity.name = "GoalEntity"
        goalEntity.managedObjectClassName = "GoalEntity"
        
        let goalAttributes: [String: NSAttributeDescription] = [
            "id": Self.createAttribute("id", .UUIDAttributeType),
            "title": Self.createAttribute("title", .stringAttributeType),
            "targetAmount": Self.createAttribute("targetAmount", .doubleAttributeType),
            "savedAmount": Self.createAttribute("savedAmount", .doubleAttributeType),
            "dueDate": Self.createAttribute("dueDate", .dateAttributeType),
            "note": Self.createOptionalAttribute("note", .stringAttributeType),
            "category": Self.createAttribute("category", .stringAttributeType),
            "monthlyContributions": Self.createOptionalAttribute("monthlyContributions", .binaryDataAttributeType),
            "lastUpdateDate": Self.createAttribute("lastUpdateDate", .dateAttributeType)
        ]
        goalEntity.properties = Array(goalAttributes.values)
        
        // PlannedPaymentEntity
        let plannedPaymentEntity = NSEntityDescription()
        plannedPaymentEntity.name = "PlannedPaymentEntity"
        plannedPaymentEntity.managedObjectClassName = "PlannedPaymentEntity"
        
        let plannedPaymentAttributes: [String: NSAttributeDescription] = [
            "id": Self.createAttribute("id", .UUIDAttributeType),
            "title": Self.createAttribute("title", .stringAttributeType),
            "amount": Self.createAttribute("amount", .doubleAttributeType),
            "dueDate": Self.createAttribute("dueDate", .dateAttributeType),
            "note": Self.createOptionalAttribute("note", .stringAttributeType),
            "isRecurring": Self.createAttribute("isRecurring", .booleanAttributeType),
            "recurringInterval": Self.createOptionalAttribute("recurringInterval", .stringAttributeType),
            "isPaid": Self.createAttribute("isPaid", .booleanAttributeType)
        ]
        plannedPaymentEntity.properties = Array(plannedPaymentAttributes.values)
        
        // Model'e entity'leri ekle
        model.entities = [transactionEntity, goalEntity, plannedPaymentEntity]
        
        // Container oluştur
        container = NSPersistentContainer(name: "FinansDostu", managedObjectModel: model)
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Preview için örnek veriler
        let sampleGoal = NSEntityDescription.insertNewObject(forEntityName: "GoalEntity", into: viewContext) 
        sampleGoal.setValue(UUID(), forKey: "id")
        sampleGoal.setValue("Yeni Araba", forKey: "title")
        sampleGoal.setValue(400000.0, forKey: "targetAmount")
        sampleGoal.setValue(150000.0, forKey: "savedAmount")
        sampleGoal.setValue(Date().addingTimeInterval(60*60*24*365), forKey: "dueDate")
        sampleGoal.setValue("araba", forKey: "category")
        sampleGoal.setValue(Date(), forKey: "lastUpdateDate")
        
        let samplePayment = NSEntityDescription.insertNewObject(forEntityName: "PlannedPaymentEntity", into: viewContext) 
        samplePayment.setValue(UUID(), forKey: "id")
        samplePayment.setValue("Kira", forKey: "title")
        samplePayment.setValue(5000.0, forKey: "amount")
        samplePayment.setValue(Date().addingTimeInterval(60*60*24*30), forKey: "dueDate")
        samplePayment.setValue(true, forKey: "isRecurring")
        samplePayment.setValue("month", forKey: "recurringInterval")
        samplePayment.setValue(false, forKey: "isPaid")
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError)")
        }
        
        return result
    }()
} 
