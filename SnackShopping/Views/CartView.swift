import SwiftUI

struct CartView: View {
    @EnvironmentObject private var catalog: CatalogStore
    @EnvironmentObject private var cart: CartStore

    private var lines: [(snack: Snack, quantity: Int)] {
        cart.lines(in: catalog.snacks)
    }

    private var subtotal: Double { cart.subtotal(snacks: catalog.snacks) }
    private var delivery: Double { Delivery.fee(for: subtotal) }
    private var total: Double { PriceMatch.roundMoney(subtotal + delivery) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ShopHeader()
                Text("Cart")
                    .font(ShopTheme.display(36))
                    .foregroundStyle(ShopTheme.ink)
                if catalog.status == .loading && lines.isEmpty && cart.count > 0 {
                    EmptyNote(title: "Opening the bag", message: "The menu is still loading.")
                } else if lines.isEmpty {
                    EmptyNote(title: "The bag is empty", message: "Add a snack from the shelf and it will wait here.")
                } else {
                    ForEach(lines, id: \.snack.id) { line in
                        lineRow(line.snack, line.quantity)
                    }
                    summary
                    NavigationLink(value: CartRoute.checkout) {
                        Text("Checkout")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(ShopTheme.gradient)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Checkout")
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 8)
            .padding(.bottom, 12)
        }
        .background(ShopTheme.paper)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private func lineRow(_ snack: Snack, _ quantity: Int) -> some View {
        HStack(spacing: 12) {
            RemoteImage(url: snack.photoURL, emoji: snack.emoji)
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(snack.name)
                    .font(ShopTheme.display(18))
                    .foregroundStyle(ShopTheme.ink)
                Text("\(ShopTheme.money(snack.price)) each · \(ShopTheme.money(snack.price * Double(quantity)))")
                    .font(.caption)
                    .foregroundStyle(ShopTheme.muted)
            }
            Spacer(minLength: 8)
            QtyControl(value: quantity) {
                cart.set(snack.id, quantity - 1)
            } increment: {
                cart.set(snack.id, quantity + 1)
            }
        }
        .padding(12)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var summary: some View {
        VStack(spacing: 8) {
            row("Snacks", subtotal)
            row("Delivery", delivery)
            row("To pay", total, strong: true)
            Text(subtotal >= Delivery.freeAt ? "Delivery is free on this bag." : "Delivery is free from \(ShopTheme.money(Delivery.freeAt)).")
                .font(.footnote)
                .foregroundStyle(ShopTheme.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
        }
    }

    private func row(_ title: String, _ amount: Double, strong: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(strong ? .headline : .body)
            Spacer()
            Text(ShopTheme.money(amount))
                .font(strong ? .headline : .body)
        }
        .foregroundStyle(ShopTheme.ink)
    }
}
