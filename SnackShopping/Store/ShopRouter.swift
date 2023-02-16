import Combine
import SwiftUI

@MainActor
final class ShopRouter: ObservableObject {
    @Published var tab: ShopTab = .home
    @Published var homePath = NavigationPath()
    @Published var searchPath = NavigationPath()
    @Published var cartPath = NavigationPath()

    func showCart() {
        tab = .cart
    }

    func shopAgain() {
        cartPath = NavigationPath()
        tab = .home
    }
}
