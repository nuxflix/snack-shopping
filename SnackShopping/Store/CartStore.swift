import Combine
import Foundation

@MainActor
final class CartStore: ObservableObject {
    @Published private(set) var quantities: [String: Int] = [:]

    private let key = "snack-shopping-cart"

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let saved = try? JSONDecoder().decode([String: Int].self, from: data) {
            quantities = saved
        }
    }

    var count: Int {
        quantities.values.reduce(0, +)
    }

    func quantity(for id: String) -> Int {
        quantities[id, default: 0]
    }

    func set(_ id: String, _ quantity: Int) {
        let next = Qty.clamp(quantity, allowZero: true)
        if next == 0 {
            quantities.removeValue(forKey: id)
        } else {
            quantities[id] = next
        }
        save()
    }

    func add(_ id: String, _ quantity: Int) {
        set(id, quantity(for: id) + quantity)
    }

    func clear() {
        quantities = [:]
        save()
    }

    func subtotal(snacks: [Snack]) -> Double {
        let prices = Dictionary(uniqueKeysWithValues: snacks.map { ($0.id, $0.price) })
        return CartMath.subtotal(prices: prices, quantities: quantities)
    }

    func lines(in snacks: [Snack]) -> [(snack: Snack, quantity: Int)] {
        snacks.compactMap { snack in
            let quantity = quantities[snack.id, default: 0]
            return quantity > 0 ? (snack, quantity) : nil
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(quantities) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
