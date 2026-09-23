import Foundation

struct LineItem: Hashable, Sendable, Codable {
    let name: String
    let price: Money
    let quantity: Int

    var total: Money {
        Money(cents: price.cents * quantity)
    }
}

struct Order: Identifiable, Sendable {
    let identifier: UUID
    var items: [LineItem]
    var paymentMethod: PaymentMethod
    var discount: DiscountCode?

    var id: UUID { identifier }

    var total: Money {
        items.reduce(Money(cents: 0)) { $0 + $1.total }
    }
}
