import SwiftUI
import UIKit

struct DetailView: View {
    var snackID: String

    @EnvironmentObject private var catalog: CatalogStore
    @EnvironmentObject private var cart: CartStore
    @EnvironmentObject private var router: ShopRouter
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var quantity = 1

    private var snack: Snack? { catalog.snack(id: snackID) }

    var body: some View {
        Group {
            if let snack {
                detail(snack)
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    backButton
                    EmptyNote(title: "That snack is gone", message: "It left the menu. Pick another one.")
                }
                .padding(18)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .background(ShopTheme.paper)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private func detail(_ snack: Snack) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                hero(snack)
                VStack(alignment: .leading, spacing: 8) {
                    Text(kicker(snack))
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.2)
                        .foregroundStyle(ShopTheme.coral)
                    Text(snack.name)
                        .font(ShopTheme.display(36))
                        .foregroundStyle(ShopTheme.ink)
                    Text(ShopTheme.money(snack.price))
                        .font(.title3.weight(.semibold))
                    Text(PriceCaption.text(for: snack))
                        .font(.subheadline)
                        .foregroundStyle(ShopTheme.muted)
                    Text(snack.blurb)
                        .font(.body)
                        .foregroundStyle(ShopTheme.ink.opacity(0.9))
                        .padding(.top, 4)
                }
                if !snack.ingredients.isEmpty {
                    FlowLayout(spacing: 8) {
                        ForEach(snack.ingredients, id: \.self) { item in
                            Text(item)
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(.white)
                                .clipShape(Capsule())
                        }
                    }
                }
                HStack(spacing: 12) {
                    QtyControl(value: quantity) {
                        quantity = Qty.clamp(quantity - 1)
                    } increment: {
                        quantity = Qty.clamp(quantity + 1)
                    }
                    Button {
                        cart.add(snack.id, quantity)
                        if !reduceMotion {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                        router.showCart()
                    } label: {
                        Text("Add to cart")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(ShopTheme.gradient)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Add to cart")
                }
                .padding(.top, 4)
                related(to: snack)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 16)
        }
        .background(ShopTheme.paper)
        .onAppear { catalog.remember(snack.id) }
    }

    private func hero(_ snack: Snack) -> some View {
        ZStack(alignment: .topLeading) {
            RemoteImage(url: snack.photoURL, emoji: snack.emoji)
                .frame(height: 280)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            backButton
                .padding(12)
        }
        .padding(.top, 8)
    }

    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Text("Back")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(ShopTheme.ink)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.white.opacity(0.92))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func kicker(_ snack: Snack) -> String {
        [snack.category, snack.area].compactMap { $0 }.joined(separator: " · ").uppercased()
    }

    private func related(to snack: Snack) -> some View {
        let more = catalog.snacks.filter { $0.category == snack.category && $0.id != snack.id }.prefix(6)
        return VStack(alignment: .leading, spacing: 10) {
            if !more.isEmpty {
                Text("More \(snack.category.lowercased())")
                    .font(ShopTheme.display(28))
                    .foregroundStyle(ShopTheme.ink)
                    .padding(.top, 8)
                ForEach(Array(more)) { item in
                    SnackCard(snack: item)
                }
            }
        }
    }
}
