import CoreData
import Foundation

/// Core Data implementation of `OrderStore`. The only file that knows
/// Core Data exists.
actor CoreDataOrderStore: OrderStore {
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
        let encodedItems = try JSONEncoder().encode(order.items)
        let context = container.newBackgroundContext()
        try await context.perform {
            let record = NSEntityDescription.insertNewObject(forEntityName: "OrderRecord", into: context)
            record.setValue(order.identifier, forKey: "identifier")
            record.setValue(order.total.cents, forKey: "totalCents")
            record.setValue(order.paymentMethod.rawValue, forKey: "paymentMethod")
            record.setValue(encodedItems, forKey: "lineItems")
            record.setValue(order.discount?.value, forKey: "discountCode")
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
                    let method = PaymentMethod(rawValue: methodName),
                    let encodedItems = record.value(forKey: "lineItems") as? Data,
                    let items = try? JSONDecoder().decode([LineItem].self, from: encodedItems)
                else { return nil }
                let discount = (record.value(forKey: "discountCode") as? String).map(DiscountCode.init)
                return Order(identifier: identifier, items: items, paymentMethod: method, discount: discount)
            }
        }
    }

    private static func makeModel() -> NSManagedObjectModel {
        let entity = NSEntityDescription()
        entity.name = "OrderRecord"
        entity.properties = [
            attribute("identifier", .UUIDAttributeType),
            attribute("totalCents", .integer64AttributeType),
            attribute("paymentMethod", .stringAttributeType),
            attribute("lineItems", .binaryDataAttributeType),
            optionalAttribute("discountCode", .stringAttributeType)
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

    private static func optionalAttribute(_ name: String, _ type: NSAttributeType) -> NSAttributeDescription {
        let attribute = attribute(name, type)
        attribute.isOptional = true
        return attribute
    }
}
