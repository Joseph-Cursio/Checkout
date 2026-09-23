import Foundation
import PropertyBased
@testable import Checkout

enum OrderGen {
    static let paymentMethods: [PaymentMethod] = [.card, .paypal, .bankTransfer, .giftCard, .storeCredit]

    static let lineItem = zip(
        Gen.letterOrNumber.string(of: 1...12),
        Gen<Int>.int(in: 1...50_000),
        Gen<Int>.int(in: 1...5)
    ).map { name, cents, quantity in
        LineItem(name: name, price: Money(cents: cents), quantity: quantity)
    }

    static let order = zip(
        Gen<Int>.int(in: 0...999_999_999),
        lineItem.array(of: 0...3),
        Gen<PaymentMethod?>.element(of: paymentMethods),
        Gen.letterOrNumber.string(of: 1...8).optional()
    ).map { serial, items, method, code in
        Order(
            identifier: UUID(uuidString: String(format: "00000000-0000-0000-0000-%012d", serial))!,
            items: items,
            paymentMethod: method ?? .card,
            discount: code.map(DiscountCode.init)
        )
    }
}
