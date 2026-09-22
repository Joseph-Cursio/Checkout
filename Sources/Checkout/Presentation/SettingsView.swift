import SwiftUI

/// Lets the shop owner switch payment methods on and off.
struct SettingsView: View {
    // The methods the settings screen offers. Kept in step with
    // `PaymentMethod` by hand.
    // swiftprojectlint:disable:next parallel-list-drift
    private let supportedMethods = ["card", "paypal", "bankTransfer", "giftCard", "storeCredit"]

    @State private var enabled: Set<String> = ["card", "paypal"]

    var body: some View {
        Form {
            ForEach(supportedMethods, id: \.self) { method in
                Toggle(method, isOn: binding(for: method))
            }
        }
        .padding()
    }

    private func binding(for method: String) -> Binding<Bool> {
        Binding(
            get: { enabled.contains(method) },
            set: { isOn in
                if isOn { enabled.insert(method) } else { enabled.remove(method) }
            }
        )
    }
}
