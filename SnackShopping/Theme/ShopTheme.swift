import SwiftUI

enum ShopTheme {
    static let paper = Color(red: 0.984, green: 0.969, blue: 0.973)
    static let ink = Color(red: 0.141, green: 0.086, blue: 0.184)
    static let muted = Color(red: 0.420, green: 0.369, blue: 0.471)
    static let line = Color(red: 0.910, green: 0.875, blue: 0.910)
    static let coral = Color(red: 1.0, green: 0.416, blue: 0.345)
    static let violet = Color(red: 0.486, green: 0.302, blue: 1.0)

    static var gradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.478, blue: 0.431),
                Color(red: 0.910, green: 0.365, blue: 0.604),
                Color(red: 0.486, green: 0.302, blue: 1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func display(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }

    static func money(_ amount: Double) -> String {
        String(format: "$%.2f", amount)
    }
}

struct ShelfTile: Identifiable {
    var id: String { name }
    var name: String
    var blurb: String
    var emoji: String
    var colors: [Color]

    static let all: [ShelfTile] = [
        ShelfTile(name: "Sweet", blurb: "Cakes, cookies, chocolate", emoji: "🍪", colors: [Color(red: 1, green: 0.42, blue: 0.48), Color(red: 1, green: 0.55, blue: 0.72)]),
        ShelfTile(name: "Savory", blurb: "Warm kitchen plates", emoji: "🥙", colors: [Color(red: 0.45, green: 0.28, blue: 0.92), Color(red: 0.28, green: 0.22, blue: 0.62)]),
        ShelfTile(name: "Fresh", blurb: "Breakfast and fruit", emoji: "🍊", colors: [Color(red: 1, green: 0.62, blue: 0.22), Color(red: 0.96, green: 0.38, blue: 0.18)]),
        ShelfTile(name: "Market", blurb: "Grocery shelf prices", emoji: "🛒", colors: [Color(red: 0.18, green: 0.72, blue: 0.62), Color(red: 0.08, green: 0.48, blue: 0.52)])
    ]

    var gradient: LinearGradient {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
