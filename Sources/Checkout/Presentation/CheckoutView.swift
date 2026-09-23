import SwiftUI

struct CheckoutView: View {
    @State var model: CheckoutViewModel

    var body: some View {
        Form {
            Section("Items") {
                ForEach(model.order.items, id: \.self) { item in
                    LabeledContent(item.name, value: item.total.formatted)
                }
            }
            Section("Total") {
                Text(model.order.total.formatted)
                    .font(.headline)
            }
            Button("Place order") {
                Task { await model.placeOrder(isGift: false) }
            }
        }
        .padding()
    }
}
