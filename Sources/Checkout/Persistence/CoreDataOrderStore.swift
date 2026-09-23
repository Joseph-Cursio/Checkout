import CoreData
import Foundation

/// Core Data implementation of `OrderStore`. The only file that knows
/// Core Data exists.
actor CoreDataOrderStore: OrderSaving, OrderHistory, OrderAdministration, AnalyticsRecording {
    private let container: NSPersistentContainer

    init(inMemory: Bool = true) {
        container = NSPersistentContainer(name: "Checkout", managedObjectModel: Self.makeModel())
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error {
                assertionFailure("Store failed to load: \(error)")
            }
        }
    }

    func save(_ order: Order) async throws {
        let context = container.newBackgroundContext()
        try await context.perform {
            let record = NSEntityDescription.insertNewObject(forEntityName: "OrderRecord", into: context)
            record.setValue(order.identifier, forKey: "identifier")
            record.setValue(order.total.cents, forKey: "totalCents")
            record.setValue(order.paymentMethod.rawValue, forKey: "paymentMethod")
            try context.save()
        }
    }

    func recentOrders() async throws -> [Order] {
        let context = container.newBackgroundContext()
        return try await context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "OrderRecord")
            return try context.fetch(request).compactMap { record in
                guard
                    let identifier = record.value(forKey: "identifier") as? UUID,
                    let methodName = record.value(forKey: "paymentMethod") as? String,
                    let method = PaymentMethod(rawValue: methodName)
                else { return nil }
                return Order(identifier: identifier, items: [], paymentMethod: method, discount: nil)
            }
        }
    }

    private static func makeModel() -> NSManagedObjectModel {
        let entity = NSEntityDescription()
        entity.name = "OrderRecord"
        entity.properties = [
            attribute("identifier", .UUIDAttributeType),
            attribute("totalCents", .integer64AttributeType),
            attribute("paymentMethod", .stringAttributeType)
        ]
        let model = NSManagedObjectModel()
        model.entities = [entity]
        return model
    }

    private static func attribute(_ name: String, _ type: NSAttributeType) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        return attribute
    }
}
