import Foundation

/// What the rest of the app needs from storage. `Domain/` owns the protocol;
/// `Persistence/` supplies an implementation; `App/` wires the two together.
///
/// It has grown: every feature that touched orders added a requirement here.
protocol OrderStore: Sendable {
    func save(_ order: Order) async throws
    func recentOrders() async throws -> [Order]
    func order(withIdentifier identifier: UUID) async throws -> Order?
    func cancel(_ identifier: UUID) async throws
    func refund(_ identifier: UUID, amount: Money) async throws
    func receiptText(for identifier: UUID) async throws -> String
    func exportCSV() async throws -> String
    func orderCount() async throws -> Int
    func deleteAll() async throws
    func recordAnalyticsEvent(_ name: String) async
}
