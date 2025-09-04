import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var catalog: CatalogStore
    @EnvironmentObject private var favorites: FavoritesStore
    @AppStorage("snack-shopping-category") private var category = "All"
    @AppStorage("snack-shopping-sort") private var sort = "name"

    private let chips = ["All", "Sweet", "Savory", "Fresh", "Quick", "Top", "Market", "Saved"]
    private let rails: [(String, String)] = [
        ("Sweet tooth", "Sweet"),
        ("Savory bites", "Savory"),
        ("Fresh", "Fresh"),
        ("Quick bites", "Quick"),
        ("From the market", "Market")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ShopHeader()
                chipRow
                sortRow
                bodyContent
            }
            .padding(.horizontal, 18)
            .padding(.top, 8)
            .padding(.bottom, 12)
        }
        .background(ShopTheme.paper)
        .refreshable { await catalog.reload(fresh: true) }
    }

    private var chipRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(chips, id: \.self) { chip in
                    Button(chip) { category = chip }
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(category == chip ? ShopTheme.ink : Color.white)
                        .foregroundStyle(category == chip ? Color.white : ShopTheme.ink)
                        .clipShape(Capsule())
                        .accessibilityAddTraits(category == chip ? .isSelected : [])
                }
            }
        }
    }

    private var sortRow: some View {
        HStack {
            Button("Refresh menu") {
                Task { await catalog.reload(fresh: true) }
            }
            .font(.subheadline.weight(.bold))
            .foregroundStyle(ShopTheme.coral)
            Spacer()
            Picker("Sort", selection: $sort) {
                Text("Name").tag("name")
                Text("Price").tag("price")
            }
            .pickerStyle(.menu)
        }
    }

    @ViewBuilder
    private var bodyContent: some View {
        if catalog.status == .loading && catalog.snacks.isEmpty {
            skeleton
        } else if catalog.status == .failed && catalog.snacks.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                EmptyNote(title: "The menu did not load", message: catalog.message ?? "Check the connection and try again.")
                PrimaryButton(title: "Try again") {
                    Task { await catalog.reload(fresh: true) }
                }
            }
        } else if category == "All" {
            if let featured = CatalogLogic.filter(catalog.snacks, category: "Sweet", sort: sort, savedIDs: favorites.ids).first ?? catalog.snacks.first {
                featuredCard(featured)
            }
            if catalog.usingSample {
                Text(catalog.message ?? "Showing the counter samples until the live menu loads.")
                    .font(.footnote)
                    .foregroundStyle(ShopTheme.muted)
            }
            RailSection(title: "Picked for you", snacks: CatalogLogic.recommend(catalog.snacks, recentIDs: catalog.recentIDs)) {
                category = "Sweet"
            }
            ForEach(rails, id: \.1) { rail in
                RailSection(title: rail.0, snacks: snacks(for: rail.1)) {
                    category = rail.1
                }
            }
            RailSection(title: "Saved for later", snacks: snacks(for: "Saved"), onSeeAll: nil)
        } else if visible.isEmpty {
            EmptyNote(title: "Nothing in this filter", message: "Save a snack, or try another shelf.")
        } else {
            LazyVStack(spacing: 12) {
                ForEach(visible) { snack in
                    SnackCard(snack: snack)
                }
            }
        }
    }

    private var visible: [Snack] {
        CatalogLogic.filter(catalog.snacks, category: category, sort: sort, savedIDs: favorites.ids)
    }

    private func snacks(for category: String) -> [Snack] {
        CatalogLogic.filter(catalog.snacks, category: category, sort: sort, savedIDs: favorites.ids)
    }

    private func featuredCard(_ snack: Snack) -> some View {
        NavigationLink(value: SnackRoute(id: snack.id)) {
            HStack(spacing: 14) {
                RemoteImage(url: snack.photoURL, emoji: snack.emoji)
                    .frame(width: 112, height: 112)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                VStack(alignment: .leading, spacing: 6) {
                    Text("ON THE COUNTER")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1.1)
                    Text(snack.name)
                        .font(ShopTheme.display(26))
                        .lineLimit(2)
                    Text(Blurb.short(snack.blurb))
                        .font(.subheadline)
                        .lineLimit(3)
                    Text(ShopTheme.money(snack.price))
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(14)
            .background(ShopTheme.gradient)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: ShopTheme.violet.opacity(0.25), radius: 16, y: 10)
        }
        .buttonStyle(.plain)
    }

    private var skeleton: some View {
        VStack(alignment: .leading, spacing: 14) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.white)
                .frame(height: 148)
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.white)
                    .frame(width: 168, height: 210)
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.white)
                    .frame(width: 168, height: 210)
            }
        }
        .accessibilityLabel("Loading the menu")
    }
}
