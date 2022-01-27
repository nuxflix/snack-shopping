import Foundation

struct Snack: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var category: String
    var price: Double
    var emoji: String
    var blurb: String
    var tags: [String]
    var ingredients: [String]
    var prepMinutes: Int?
    var imageURL: String?
    var rating: Double?
    var area: String?
    var priceSource: String
    var priceLabel: String

    var photoURL: URL? {
        guard let imageURL, let url = URL(string: imageURL) else { return nil }
        return url
    }
}

struct SnackRoute: Hashable {
    var id: String
}

enum CartRoute: Hashable {
    case checkout
    case receipt
}

enum ShopTab: String, Hashable, CaseIterable {
    case home
    case search
    case cart

    var title: String {
        switch self {
        case .home: return "Home"
        case .search: return "Search"
        case .cart: return "Cart"
        }
    }

    var symbol: String {
        switch self {
        case .home: return "house.fill"
        case .search: return "magnifyingglass"
        case .cart: return "cart.fill"
        }
    }
}
