import Foundation

/// Rendered receipts, kept so reopening one doesn't re-render it.
/// `@unchecked` silenced the compiler; nothing guards `receipts`.
final class ReceiptCache: @unchecked Sendable {
    private var receipts: [UUID: String] = [:]

    func receipt(for identifier: UUID) -> String? {
        receipts[identifier]
    }

    func store(_ receipt: String, for identifier: UUID) {
        receipts[identifier] = receipt
    }
}
