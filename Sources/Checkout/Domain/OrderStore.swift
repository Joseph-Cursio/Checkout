import Foundation

// `OrderStore` used to be one ten-requirement protocol. Each screen needed a
// different slice of it, so it's now three roles. A client asks for exactly
// the roles it uses, and composes them with `&` when it needs more than one.

/// Saving new orders. What checkout needs.
protocol OrderSaving: Sendable {
    func save(_ order: Order) async throws
}

/// Reading past orders. What order history and receipts need.
protocol OrderHistory: Sendable {
    func recentOrders() async throws -> [Order]
    func order(withIdentifier identifier: UUID) async throws -> Order?
    func receiptText(for identifier: UUID) async throws -> String
    func orderCount() async throws -> Int
}

/// Changing or removing orders after the fact. What admin tools need.
protocol OrderAdministration: Sendable {
    func cancel(_ identifier: UUID) async throws
    func refund(_ identifier: UUID, amount: Money) async throws
    func exportCSV() async throws -> String
    func deleteAll() async throws
}

/// Recording analytics events.
protocol AnalyticsRecording: Sendable {
    func recordAnalyticsEvent(_ name: String) async
}

/// Everything a full storage backend provides.
typealias OrderStore = OrderSaving & OrderHistory & OrderAdministration & AnalyticsRecording
