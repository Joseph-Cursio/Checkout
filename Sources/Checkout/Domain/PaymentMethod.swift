/// Every way a customer can pay.
enum PaymentMethod: String, Sendable {
    case card
    case paypal
    case bankTransfer
    case giftCard
    case storeCredit
}
