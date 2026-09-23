import Foundation
import PropertyBased
import Testing
@testable import Checkout

/// A law `OrderStore` never stated: saving the same order twice should leave
/// one order, so a double tap or a retried save can't create a duplicate.
///
/// Both stores fail it, in the same way: each keeps two copies. They're
/// substitutable (they agree with each other) and both wrong.
@Test("saving the same order twice stores it once", arguments: StoreKind.allCases)
func saveTwiceStoresOnce(kind: StoreKind) async throws {
    await propertyCheck(input: OrderGen.order) { order in
        let store = kind.makeStore()
        try await store.save(order)
        try await store.save(order)
        let copies = try await store.recentOrders().filter { $0.identifier == order.identifier }
        #expect(copies.count == 1)
    }
}
