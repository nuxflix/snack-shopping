import SwiftUI

struct CheckoutView: View {
    @EnvironmentObject private var catalog: CatalogStore
    @EnvironmentObject private var cart: CartStore
    @EnvironmentObject private var orders: OrderStore
    @EnvironmentObject private var router: ShopRouter
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var window = "Afternoon"
    @State private var note = ""

    private let draftKey = "snack-shopping-draft"
    private let windows = ["Morning", "Afternoon", "Evening"]

    private var subtotal: Double { cart.subtotal(snacks: catalog.snacks) }
    private var delivery: Double { Delivery.fee(for: subtotal) }
    private var total: Double { PriceMatch.roundMoney(subtotal + delivery) }
    private var canPlace: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !cart.lines(in: catalog.snacks).isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Button("Back to cart") { dismiss() }
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(ShopTheme.coral)
                Text("Checkout")
                    .font(ShopTheme.display(36))
                    .foregroundStyle(ShopTheme.ink)
                Text("Snacks \(ShopTheme.money(subtotal)) · Delivery \(ShopTheme.money(delivery)) · To pay \(ShopTheme.money(total))")
                    .foregroundStyle(ShopTheme.muted)
                field("Name", text: $name)
                field("Phone", text: $phone)
                field("Address", text: $address, axis: .vertical)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Delivery window")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(ShopTheme.ink)
                    Picker("Delivery window", selection: $window) {
                        ForEach(windows, id: \.self) { item in
                            Text(item).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                field("Note", text: $note, axis: .vertical)
                Button {
                    place()
                } label: {
                    Text("Place order")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(canPlace ? AnyShapeStyle(ShopTheme.gradient) : AnyShapeStyle(ShopTheme.muted.opacity(0.4)))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(!canPlace)
            }
            .padding(18)
        }
        .background(ShopTheme.paper)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear(perform: loadDraft)
        .onChange(of: name) { _ in saveDraft() }
        .onChange(of: phone) { _ in saveDraft() }
        .onChange(of: address) { _ in saveDraft() }
        .onChange(of: window) { _ in saveDraft() }
        .onChange(of: note) { _ in saveDraft() }
    }

    private func field(_ title: String, text: Binding<String>, axis: Axis = .horizontal) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(ShopTheme.ink)
            TextField(title, text: text, axis: axis)
                .lineLimit(axis == .vertical ? 3...5 : 1...1)
                .padding(14)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private func place() {
        let lines = cart.lines(in: catalog.snacks)
        guard canPlace else { return }
        _ = orders.place(
            customer: name.trimmingCharacters(in: .whitespacesAndNewlines),
            address: address.trimmingCharacters(in: .whitespacesAndNewlines),
            window: window,
            lines: lines
        )
        cart.clear()
        UserDefaults.standard.removeObject(forKey: draftKey)
        router.cartPath.append(CartRoute.receipt)
    }

    private func loadDraft() {
        guard let data = UserDefaults.standard.data(forKey: draftKey),
              let draft = try? JSONDecoder().decode(Draft.self, from: data) else { return }
        name = draft.name
        phone = draft.phone
        address = draft.address
        window = draft.window
        note = draft.note
    }

    private func saveDraft() {
        let draft = Draft(name: name, phone: phone, address: address, window: window, note: note)
        if let data = try? JSONEncoder().encode(draft) {
            UserDefaults.standard.set(data, forKey: draftKey)
        }
    }

    private struct Draft: Codable {
        var name: String
        var phone: String
        var address: String
        var window: String
        var note: String
    }
}
