/// A promotional code, normalised to upper case on creation.
struct DiscountCode: Hashable, Sendable {
    let value: String

    init(_ raw: String) {
        value = raw.uppercased()
    }
}
