import SwiftUI

struct RootView: View {
    @EnvironmentObject private var router: ShopRouter
    @EnvironmentObject private var cart: CartStore

    var body: some View {
        Group {
            switch router.tab {
            case .home:
                NavigationStack(path: $router.homePath) {
                    HomeView()
                        .navigationDestination(for: SnackRoute.self) { route in
                            DetailView(snackID: route.id)
                        }
                }
            case .search:
                NavigationStack(path: $router.searchPath) {
                    SearchView()
                        .navigationDestination(for: SnackRoute.self) { route in
                            DetailView(snackID: route.id)
                        }
                }
            case .cart:
                NavigationStack(path: $router.cartPath) {
                    CartView()
                        .navigationDestination(for: CartRoute.self) { route in
                            switch route {
                            case .checkout:
                                CheckoutView()
                            case .receipt:
                                OrderView()
                            }
                        }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ShopTheme.paper.ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            ShopTabBar(tab: $router.tab, count: cart.count)
                .background(ShopTheme.paper.ignoresSafeArea(edges: .bottom))
        }
    }
}
