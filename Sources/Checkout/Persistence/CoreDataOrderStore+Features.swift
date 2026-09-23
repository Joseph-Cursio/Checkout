import Foundation

/// The requirements `OrderStore` gained after launch. Each is simple on its
/// own; together they make every conformer implement all of them.
extension CoreDataOrderStore {
    func order(withIdentifier identifier: UUID) async throws -> Order? {
        try await recentOrders().first { $0.identifier == identifier }
    }

    func cancel(_ identifier: UUID) async throws {}

    func refund(_ identifier: UUID, amount: Money) async throws {}

    func receiptText(for identifier: UUID) async throws -> String {
        guard let order = try await order(withIdentifier: identifier) else { return "" }
        return "Order \(order.identifier): \(order.total.formatted)"
    }

    func exportCSV() async throws -> String {
        try await recentOrders()
            .map { "\($0.identifier),\($0.paymentMethod.rawValue)" }
            .joined(separator: "\n")
    }

    func orderCount() async throws -> Int {
        try await recentOrders().count
    }

    func deleteAll() async throws {}

    func recordAnalyticsEvent(_ name: String) async {}
}
