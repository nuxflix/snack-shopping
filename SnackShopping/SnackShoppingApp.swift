import SwiftUI

@main
struct SnackShoppingApp: App {
    @StateObject private var catalog = CatalogStore()
    @StateObject private var cart = CartStore()
    @StateObject private var favorites = FavoritesStore()
    @StateObject private var orders = OrderStore()
    @StateObject private var router = ShopRouter()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(catalog)
                .environmentObject(cart)
                .environmentObject(favorites)
                .environmentObject(orders)
                .environmentObject(router)
                .preferredColorScheme(.light)
        }
    }
}
