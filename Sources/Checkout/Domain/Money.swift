import Foundation

/// An amount of money in minor units (cents), so arithmetic never rounds.
struct Money: Hashable, Sendable, Comparable {
    let cents: Int

    static func + (lhs: Money, rhs: Money) -> Money {
        Money(cents: lhs.cents + rhs.cents)
    }

    static func < (lhs: Money, rhs: Money) -> Bool {
        lhs.cents < rhs.cents
    }

    var formatted: String {
        let amount = Decimal(cents) / 100
        return amount.formatted(.currency(code: "USD"))
    }
}
