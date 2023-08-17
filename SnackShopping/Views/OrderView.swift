import SwiftUI

struct OrderView: View {
    @EnvironmentObject private var orders: OrderStore
    @EnvironmentObject private var router: ShopRouter

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if let order = orders.latest {
                    Text("ORDER PLACED")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.2)
                        .foregroundStyle(ShopTheme.coral)
                    Text(order.id)
                        .font(ShopTheme.display(34))
                        .foregroundStyle(ShopTheme.ink)
                    Text("Thanks, \(order.customer). We will bring this to \(order.address) in the \(order.window.lowercased()).")
                        .foregroundStyle(ShopTheme.ink)
                    ForEach(order.lines) { line in
                        HStack {
                            Text("\(line.name) × \(line.quantity)")
                            Spacer()
                            Text(ShopTheme.money(line.price * Double(line.quantity)))
                                .foregroundStyle(ShopTheme.muted)
                        }
                    }
                    HStack {
                        Text("Total")
                            .font(.headline)
                        Spacer()
                        Text(ShopTheme.money(order.total))
                            .font(.headline)
                    }
                    .padding(.top, 6)
                    Button("Order something else") {
                        router.shopAgain()
                    }
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(ShopTheme.coral)
                    .padding(.top, 8)
                    let earlier = orders.orders.dropFirst()
                    if !earlier.isEmpty {
                        Text("Earlier orders")
                            .font(ShopTheme.display(26))
                            .padding(.top, 12)
                        ForEach(Array(earlier)) { past in
                            Text("\(past.id) · \(ShopTheme.money(past.total))")
                                .foregroundStyle(ShopTheme.muted)
                        }
                    }
                } else {
                    EmptyNote(title: "No order yet", message: "Checkout from the bag and the receipt will stay on this iPhone.")
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(ShopTheme.paper)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}
