import SwiftUI

struct ShopHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Snack Shopping")
                .font(ShopTheme.display(40))
                .foregroundStyle(ShopTheme.ink)
            Text("Snacks picked for the way you actually eat.")
                .font(.subheadline)
                .foregroundStyle(ShopTheme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

struct RemoteImage: View {
    var url: URL?
    var emoji: String

    var body: some View {
        ZStack {
            ShopTheme.line.opacity(0.45)
            Text(emoji)
                .font(.system(size: 36))
            if let url {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    }
                }
            }
        }
        .clipped()
    }
}

struct HeartButton: View {
    var saved: Bool
    var name: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: saved ? "heart.fill" : "heart")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(saved ? ShopTheme.coral : ShopTheme.ink)
                .frame(width: 32, height: 32)
                .background(.white.opacity(0.92))
                .clipShape(Circle())
                .shadow(color: ShopTheme.ink.opacity(0.08), radius: 6, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(saved ? "Remove \(name) from saved" : "Save \(name)")
    }
}

struct SnackCard: View {
    enum Style { case rail, row }

    var snack: Snack
    var style: Style = .row

    @EnvironmentObject private var favorites: FavoritesStore

    var body: some View {
        ZStack(alignment: .topTrailing) {
            NavigationLink(value: SnackRoute(id: snack.id)) {
                content
            }
            .buttonStyle(.plain)
            HeartButton(saved: favorites.contains(snack.id), name: snack.name) {
                favorites.toggle(snack.id)
            }
            .padding(10)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch style {
        case .rail:
            VStack(alignment: .leading, spacing: 8) {
                RemoteImage(url: snack.photoURL, emoji: snack.emoji)
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                Text(snack.category.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(ShopTheme.coral)
                Text(snack.name)
                    .font(ShopTheme.display(18))
                    .foregroundStyle(ShopTheme.ink)
                    .lineLimit(2)
                Text(ShopTheme.money(snack.price))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(ShopTheme.ink)
                if let prep = snack.prepMinutes {
                    Text("\(prep) min")
                        .font(.caption)
                        .foregroundStyle(ShopTheme.muted)
                }
            }
            .padding(12)
            .frame(width: 168, alignment: .leading)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: ShopTheme.ink.opacity(0.05), radius: 12, y: 6)
        case .row:
            HStack(spacing: 12) {
                RemoteImage(url: snack.photoURL, emoji: snack.emoji)
                    .frame(width: 84, height: 84)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                VStack(alignment: .leading, spacing: 4) {
                    Text(snack.category.uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(ShopTheme.coral)
                    Text(snack.name)
                        .font(ShopTheme.display(20))
                        .foregroundStyle(ShopTheme.ink)
                        .lineLimit(2)
                    HStack(spacing: 8) {
                        Text(ShopTheme.money(snack.price))
                            .font(.subheadline.weight(.semibold))
                        if let prep = snack.prepMinutes {
                            Text("\(prep) min")
                                .font(.caption)
                                .foregroundStyle(ShopTheme.muted)
                        }
                    }
                }
                Spacer(minLength: 28)
            }
            .padding(12)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: ShopTheme.ink.opacity(0.05), radius: 12, y: 6)
        }
    }
}

struct RailSection: View {
    var title: String
    var snacks: [Snack]
    var onSeeAll: (() -> Void)?

    var body: some View {
        if snacks.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(title)
                        .font(ShopTheme.display(28))
                        .foregroundStyle(ShopTheme.ink)
                    Spacer()
                    if let onSeeAll {
                        Button("See all", action: onSeeAll)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(ShopTheme.coral)
                    }
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 12) {
                        ForEach(snacks) { snack in
                            SnackCard(snack: snack, style: .rail)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 320
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: width, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(width: size.width, height: size.height))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

struct ShopTabBar: View {
    @Binding var tab: ShopTab
    var count: Int

    var body: some View {
        HStack(spacing: 10) {
            ForEach(ShopTab.allCases, id: \.self) { item in
                tabButton(item)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [ShopTheme.paper.opacity(0), ShopTheme.paper, ShopTheme.paper],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .accessibilityElement(children: .contain)
    }

    private func tabButton(_ item: ShopTab) -> some View {
        let selected = tab == item
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                tab = item
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: item.symbol)
                    .font(.system(size: 18, weight: .semibold))
                if selected {
                    Text(item.title)
                        .font(.system(size: 15, weight: .bold))
                        .lineLimit(1)
                }
                if item == .cart, count > 0 {
                    Text("\(count)")
                        .font(.system(size: 11, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(selected ? Color.white : ShopTheme.coral)
                        .foregroundStyle(selected ? ShopTheme.ink : Color.white)
                        .clipShape(Capsule())
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, selected ? 16 : 15)
            .frame(height: 52)
            .background {
                Capsule().fill(selected ? AnyShapeStyle(ShopTheme.gradient) : AnyShapeStyle(ShopTheme.ink))
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.title)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

struct EmptyNote: View {
    var title: String
    var message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(ShopTheme.display(28))
                .foregroundStyle(ShopTheme.ink)
            Text(message)
                .foregroundStyle(ShopTheme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
    }
}

struct PrimaryButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(ShopTheme.gradient)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct QtyControl: View {
    var value: Int
    var decrement: () -> Void
    var increment: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Button(action: decrement) {
                Image(systemName: "minus")
                    .frame(width: 36, height: 36)
            }
            .accessibilityLabel("Decrease quantity")
            Text("\(value)")
                .font(.headline)
                .frame(minWidth: 24)
                .accessibilityLabel("Quantity \(value)")
            Button(action: increment) {
                Image(systemName: "plus")
                    .frame(width: 36, height: 36)
            }
            .accessibilityLabel("Increase quantity")
        }
        .foregroundStyle(ShopTheme.ink)
        .padding(.horizontal, 4)
        .background(ShopTheme.paper)
        .clipShape(Capsule())
    }
}
