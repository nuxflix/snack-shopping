import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var catalog: CatalogStore
    @EnvironmentObject private var favorites: FavoritesStore
    @AppStorage("snack-shopping-sort") private var sort = "name"
    @State private var query = ""
    @State private var category = "All"

    private var results: [Snack] {
        CatalogLogic.filter(catalog.snacks, query: query, category: category, sort: sort, savedIDs: favorites.ids)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ShopHeader()
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(ShopTheme.muted)
                    TextField("Search snacks, ingredients, or recipes", text: $query)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                .padding(14)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Search snacks")

                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    ForEach(ShelfTile.all) { tile in
                        Button {
                            category = category == tile.name ? "All" : tile.name
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(tile.emoji)
                                    .font(.title2)
                                Text(tile.name)
                                    .font(ShopTheme.display(22))
                                Text(tile.blurb)
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.9))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 118, alignment: .leading)
                            .padding(14)
                            .background(tile.gradient)
                            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 26, style: .continuous)
                                    .strokeBorder(.white.opacity(category == tile.name ? 0.9 : 0), lineWidth: 3)
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(category == tile.name ? .isSelected : [])
                    }
                }

                HStack {
                    Text("\(results.count) snack\(results.count == 1 ? "" : "s")")
                        .foregroundStyle(ShopTheme.muted)
                    Spacer()
                    Picker("Sort", selection: $sort) {
                        Text("Name").tag("name")
                        Text("Price").tag("price")
                    }
                    .pickerStyle(.menu)
                }

                if catalog.status == .loading && catalog.snacks.isEmpty {
                    EmptyNote(title: "Loading the menu", message: "Photos and prices are on the way.")
                } else if results.isEmpty {
                    EmptyNote(title: "No snacks match", message: "Try another word, or clear the shelf.")
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(results) { snack in
                            SnackCard(snack: snack)
                        }
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 8)
            .padding(.bottom, 12)
        }
        .background(ShopTheme.paper)
    }
}
