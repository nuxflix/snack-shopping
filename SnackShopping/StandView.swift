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

    private var menu: [CounterSnack] {
        var list = counterMenu
        return list
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(menu) { snack in
                    row(snack)
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
}

