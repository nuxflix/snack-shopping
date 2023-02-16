import Combine
import Foundation

struct OrderLine: Codable, Hashable, Identifiable {
    var id: String { name }
    var name: String
    var quantity: Int
    var price: Double
}

struct PlacedOrder: Codable, Hashable, Identifiable {
    var id: String
    var customer: String
    var address: String
    var window: String
    var lines: [OrderLine]
    var subtotal: Double
    var delivery: Double
    var total: Double
    var created: Date
}

@MainActor
final class OrderStore: ObservableObject {
    @Published private(set) var orders: [PlacedOrder] = []

    private let key = "snack-shopping-orders"

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let saved = try? JSONDecoder().decode([PlacedOrder].self, from: data) {
            orders = saved
        }
    }

    var latest: PlacedOrder? { orders.first }

    func place(
        customer: String,
        address: String,
        window: String,
        lines: [(snack: Snack, quantity: Int)]
    ) -> PlacedOrder {
        let orderLines = lines.map { OrderLine(name: $0.snack.name, quantity: $0.quantity, price: $0.snack.price) }
        let subtotal = orderLines.reduce(0) { $0 + $1.price * Double($1.quantity) }
        let delivery = Delivery.fee(for: subtotal)
        let order = PlacedOrder(
            id: Self.makeID(),
            customer: customer,
            address: address,
            window: window,
            lines: orderLines,
            subtotal: subtotal,
            delivery: delivery,
            total: PriceMatch.roundMoney(subtotal + delivery),
            created: Date()
        )
        orders.insert(order, at: 0)
        if orders.count > 12 {
            orders = Array(orders.prefix(12))
        }
        save()
        return order
    }

    private func save() {
        if let data = try? JSONEncoder().encode(orders) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private static func makeID() -> String {
        let alphabet = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        return "SS-" + String((0..<8).map { _ in alphabet.randomElement()! })
    }
}
