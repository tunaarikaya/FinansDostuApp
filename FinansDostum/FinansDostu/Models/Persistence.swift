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
        container = NSPersistentContainer(name: "FinansDostu")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data store yüklenirken hata oluştu: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Preview için örnek veriler
        let sampleGoal = GoalEntity(context: viewContext)
        sampleGoal.id = UUID()
        sampleGoal.title = "Yeni Araba"
        sampleGoal.targetAmount = 400000.0
        sampleGoal.savedAmount = 150000.0
        sampleGoal.dueDate = Date().addingTimeInterval(60*60*24*365)
        sampleGoal.category = "araba"
        sampleGoal.lastUpdateDate = Date()
        
        let samplePayment = PlannedPaymentEntity(context: viewContext)
        samplePayment.id = UUID()
        samplePayment.title = "Kira"
        samplePayment.amount = 5000.0
        samplePayment.dueDate = Date().addingTimeInterval(60*60*24*30)
        samplePayment.isRecurring = true
        samplePayment.recurringInterval = "month"
        samplePayment.isPaid = false
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Core Data preview verisi kaydedilirken hata oluştu: \(nsError)")
        }
        
        return result
    }()

    func delete(_ transaction: Transaction) {
        let context = container.viewContext
        let request = NSFetchRequest<TransactionEntity>(entityName: "TransactionEntity")
        request.predicate = NSPredicate(format: "id == %@", transaction.id as CVarArg)
        
        do {
            let results = try context.fetch(request)
            if let entityToDelete = results.first {
                context.delete(entityToDelete)
                try context.save()
            }
        } catch {
            print("İşlem silinirken hata oluştu: \(error)")
        }
    }
} 
