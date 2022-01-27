import Foundation

enum Delivery {
    static let fee = 3.5
    static let freeAt = 35.0

    static func fee(for subtotal: Double) -> Double {
        if subtotal <= 0 { return 0 }
        if subtotal >= freeAt { return 0 }
        return fee
    }
}

enum Qty {
    static func clamp(_ value: Int, allowZero: Bool = false) -> Int {
        min(20, max(allowZero ? 0 : 1, value))
    }
}

enum CartMath {
    static func subtotal(prices: [String: Double], quantities: [String: Int]) -> Double {
        quantities.reduce(0) { partial, pair in
            partial + (prices[pair.key] ?? 0) * Double(pair.value)
        }
    }
}
