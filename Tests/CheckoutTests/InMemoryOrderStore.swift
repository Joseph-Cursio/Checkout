import Foundation
@testable import Checkout

/// The test double every suite has. It keeps whole `Order` values, so it
/// round-trips everything it's given.
actor InMemoryOrderStore: OrderStore {
    private var orders: [Order] = []

    func save(_ order: Order) async throws {
        orders.append(order)
    }

    func recentOrders() async throws -> [Order] {
        orders
    }
}
