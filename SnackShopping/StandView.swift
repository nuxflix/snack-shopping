import SwiftUI

struct CounterSnack: Identifiable, Hashable {
    var id: String
    var name: String
    var category: String
    var price: Double
    var note: String
}

private let counterMenu: [CounterSnack] = [
    CounterSnack(id: "brownie", name: "Cocoa Brownie", category: "Sweet", price: 4.5, note: "A warm square with a soft middle."),
    CounterSnack(id: "tart", name: "Lemon Tart", category: "Sweet", price: 5.0, note: "A short crust and a sharp lemon curd."),
    CounterSnack(id: "twist", name: "Cheese Twist", category: "Savory", price: 3.1, note: "Puff pastry rolled with sharp cheese."),
    CounterSnack(id: "lassi", name: "Mango Lassi", category: "Fresh", price: 3.8, note: "A cold mango and yogurt drink."),
    CounterSnack(id: "chips", name: "Sea Salt Chips", category: "Savory", price: 2.75, note: "Crisp chips finished with flaky salt."),
    CounterSnack(id: "cookie", name: "Peanut Cookie", category: "Sweet", price: 2.6, note: "A thick cookie with a salted peanut center."),
]

struct StandView: View {
    @State private var query = ""
    @State private var cart: [String: Int] = [:]

    private var menu: [CounterSnack] {
        var list = counterMenu
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !needle.isEmpty { list = list.filter { $0.name.lowercased().contains(needle) } }
        return list
    }

    private var count: Int { cart.values.reduce(0, +) }
    private var subtotal: Double {
        menuSource().reduce(0) { partial, snack in
            partial + snack.price * Double(cart[snack.id] ?? 0)
        }
    }
    private var fee: Double { subtotal >= 35 ? 0 : (subtotal > 0 ? 3.5 : 0) }

    private func menuSource() -> [CounterSnack] {
        counterMenu
    }

    private func setQty(_ id: String, _ value: Int) {
        let next = min(99, max(0, value))
        if next == 0 { cart.removeValue(forKey: id) } else { cart[id] = next }
    }

    var body: some View {
        NavigationView {
            List {
                TextField("Search snacks", text: $query)
                ForEach(menu) { snack in
                    NavigationLink(destination: detail(snack)) {
                        row(snack)
                    }
                }
                NavigationLink(destination: bag) {
                    Text(count == 0 ? "Bag" : "Bag (\(count))")
                }
            }
            .navigationTitle("Snack Shopping")
        }
    }

    private func row(_ snack: CounterSnack) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(snack.name)
                Text(String(format: "$%.2f", snack.price)).foregroundColor(.secondary)
            }
        }
    }

    private func detail(_ snack: CounterSnack) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(snack.category).font(.caption).foregroundColor(.secondary)
            Text(snack.name).font(.largeTitle)
            Text(String(format: "$%.2f", snack.price))
            Text(snack.note)
            Stepper("Quantity \(cart[snack.id] ?? 1)", onIncrement: { setQty(snack.id, (cart[snack.id] ?? 1) + 1) }, onDecrement: { setQty(snack.id, max(1, (cart[snack.id] ?? 1) - 1)) })
            Button("Add to bag") {
                setQty(snack.id, (cart[snack.id] ?? 0) + (cart[snack.id] == nil ? 1 : 1))
            }
            Spacer()
        }
        .padding()
    }

    private var bag: some View {
        List {
            ForEach(menuSource().filter { (cart[$0.id] ?? 0) > 0 }) { snack in
                HStack {
                    Text(snack.name)
                    Spacer()
                    Text(String(format: "$%.2f", snack.price * Double(cart[snack.id] ?? 0)))
                }
            }
            Text(String(format: "Snacks $%.2f", subtotal))
        }
        .navigationTitle("Bag")
    }
}

