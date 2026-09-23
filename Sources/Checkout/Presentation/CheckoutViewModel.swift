import Foundation
import Observation

@MainActor
@Observable
final class CheckoutViewModel {
    private let store: any OrderStore
    private(set) var order: Order
    private(set) var lastError: String?

    init(store: any OrderStore) {
        self.store = store
        order = Order(
            identifier: UUID(),
            items: [
                LineItem(name: "Espresso beans", price: Money(cents: 1_800), quantity: 2),
                LineItem(name: "Filter papers", price: Money(cents: 450), quantity: 1)
            ],
            paymentMethod: .card,
            discount: nil
        )
    }

    func choose(_ method: PaymentMethod) {
        order.paymentMethod = method
    }

    func apply(_ code: DiscountCode) {
        order.discount = code
    }

    private(set) var giftMessage: String?
    private(set) var shippingLabel = ""

    func placeOrder(isGift: Bool) async {
        if isGift {
            giftMessage = "A gift for you"
            shippingLabel = "Ship to recipient, no prices"
            order.discount = nil
        } else {
            giftMessage = nil
            shippingLabel = "Ship to buyer"
        }
        do {
            try await store.save(order)
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }
}
