/// What the rest of the app needs from storage. `Domain/` owns the protocol;
/// `Persistence/` supplies an implementation; `App/` wires the two together.
protocol OrderStore: Sendable {
    func save(_ order: Order) async throws
    func recentOrders() async throws -> [Order]
}
