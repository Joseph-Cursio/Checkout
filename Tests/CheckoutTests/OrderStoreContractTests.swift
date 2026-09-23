import Foundation
import PropertyBased
import Testing
@testable import Checkout

/// `OrderStore`'s contract, written down once and run against every conformer.
///
/// The compiler checks that each store has the right methods. These laws check
/// that each store *behaves* the same way, so that any one of them can stand in
/// for another. That's Liskov substitution, and it's the part of it no linter
/// can see.
enum StoreKind: String, CaseIterable, Sendable, CustomTestStringConvertible {
    case inMemory
    case coreData

    var testDescription: String { rawValue }

    func makeStore() -> any OrderStore {
        switch self {
        case .inMemory: InMemoryOrderStore()
        case .coreData: CoreDataOrderStore(inMemory: true)
        }
    }
}

@Suite("OrderStore contract")
struct OrderStoreContractTests {
    /// Law: whatever you save, you get back unchanged.
    @Test("save then fetch round-trips the order", arguments: StoreKind.allCases)
    func saveThenFetchRoundTrips(kind: StoreKind) async throws {
        await propertyCheck(input: OrderGen.order) { order in
            let store = kind.makeStore()
            try await store.save(order)
            let fetched = try await store.recentOrders()
                .first { $0.identifier == order.identifier }

            #expect(fetched?.items == order.items)
            #expect(fetched?.paymentMethod == order.paymentMethod)
            #expect(fetched?.discount == order.discount)
        }
    }

    /// Law: a store returns only what was saved into it.
    @Test("fetch returns only saved orders", arguments: StoreKind.allCases)
    func fetchReturnsOnlySavedOrders(kind: StoreKind) async throws {
        await propertyCheck(input: OrderGen.order.array(of: 0...4)) { orders in
            let store = kind.makeStore()
            for order in orders {
                try await store.save(order)
            }
            let savedIdentifiers = Set(orders.map(\.identifier))
            let fetchedIdentifiers = try await store.recentOrders().map(\.identifier)

            #expect(fetchedIdentifiers.allSatisfy(savedIdentifiers.contains))
        }
    }
}
