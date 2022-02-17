import SwiftUI

struct StandView: View {
    @State private var query = UserDefaults.standard.string(forKey: "snack-stand-query") ?? ""
    @State private var category = "All"
    @State private var sortName = true
    @State private var cart: [String: Int] = [:]
    @State private var receipts: [String] = []
    @State private var customer = ""
    @State private var address = ""

    private var menu: [Snack] {
        var list = SampleMenu.all
        if category != "All" { list = list.filter { $0.category == category } }
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return CatalogLogic.filter(SampleMenu.all, query: query, category: category, sort: sortName ? "name" : "price")
    }

    private var count: Int { cart.values.reduce(0, +) }
    private var subtotal: Double {
        menuSource().reduce(0) { partial, snack in
            partial + snack.price * Double(cart[snack.id] ?? 0)
        }
    }
    private var fee: Double { Delivery.fee(for: subtotal) }

    private func menuSource() -> [Snack] {
        SampleMenu.all
    }

    private func setQty(_ id: String, _ value: Int) {
        let next = min(99, max(0, value))
        if next == 0 { cart.removeValue(forKey: id) } else { cart[id] = next }
    }

    var body: some View {
        NavigationView {
            List {
                TextField("Search snacks", text: $query)
                    .onChange(of: query) { value in UserDefaults.standard.set(value, forKey: "snack-stand-query") }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(["All", "Sweet", "Savory", "Fresh"], id: \.self) { name in
                            Button(name) { category = name }
                                .foregroundColor(category == name ? .white : .primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(category == name ? Color.black : Color.gray.opacity(0.15))
                                .cornerRadius(16)
                        }
                    }
                }
                Picker("Sort", selection: $sortName) {
                    Text("Name").tag(true)
                    Text("Price").tag(false)
                }
                .pickerStyle(.segmented)
                Text("\(menu.count) snacks").font(.footnote).foregroundColor(.secondary)
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

    private func row(_ snack: Snack) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(snack.category).font(.caption).foregroundColor(.secondary)
                Text(snack.name)
                Text(String(format: "$%.2f", snack.price)).foregroundColor(.secondary)
            }
        }
    }

    private func detail(_ snack: Snack) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(snack.category).font(.caption).foregroundColor(.secondary)
            Text(snack.name).font(.largeTitle)
            Text(String(format: "$%.2f", snack.price))
            Text(snack.blurb)
            Text("More \(snack.category.lowercased())").font(.headline)
            ForEach(SampleMenu.all.filter { $0.category == snack.category && $0.id != snack.id }) { other in
                Text(other.name)
            }
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
            if count == 0 {
                Text("The bag is empty. Add a snack from the counter.")
            }
            ForEach(menuSource().filter { (cart[$0.id] ?? 0) > 0 }) { snack in
                HStack {
                    Text(snack.name)
                    Spacer()
                    Text(String(format: "$%.2f", snack.price * Double(cart[snack.id] ?? 0)))
                }
            }
            Text(String(format: "Snacks $%.2f", subtotal))
            Text(String(format: "Delivery $%.2f", fee))
            Text(fee == 0 && subtotal > 0 ? "Delivery is free on this bag." : "Delivery is free from $35.")
                .font(.footnote)
                .foregroundColor(.secondary)
            Button("Clear bag") { cart = [:]; setQty("", 0) }
            NavigationLink(destination: checkoutForm) { Text("Checkout") }
        }
        .navigationTitle("Bag")
    }

    private var checkoutForm: some View {
        Form {
            TextField("Name", text: $customer)
            TextField("Address", text: $address)
            Button("Place order") {
                let id = "SS-\(Int.random(in: 1000...9999))"
                receipts.insert("\(id) \(customer)", at: 0)
                cart = [:]
            }
            .disabled(customer.trimmingCharacters(in: .whitespaces).isEmpty || address.trimmingCharacters(in: .whitespaces).isEmpty)
            Section("Earlier orders") {
                ForEach(receipts, id: \.self) { Text($0) }
            }
        }
        .navigationTitle("Checkout")
    }
}

