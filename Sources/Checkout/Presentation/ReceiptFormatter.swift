/// Labels for the payment line on a printed receipt.
enum ReceiptFormatter {
    static func paymentLabel(for method: PaymentMethod) -> String {
        switch method.rawValue {
        case "card": "Card"
        case "paypal": "PayPal"
        case "bankTransfer": "Bank transfer"
        case "giftCard": "Gift card"
        case "storeCredit": "Store credit"
        default: "Other"
        }
    }
}
