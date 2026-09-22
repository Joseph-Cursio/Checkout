import SwiftUI

/// The composition root: the one place that knows which `OrderStore` the app
/// uses. Files outside every layer are never judged by the layer rules.
@main
struct CheckoutApp: App {
    private let store = CoreDataOrderStore()

    var body: some Scene {
        WindowGroup {
            TabView {
                CheckoutView(model: CheckoutViewModel(store: store))
                    .tabItem { Label("Checkout", systemImage: "cart") }
                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gear") }
            }
        }
    }
}
