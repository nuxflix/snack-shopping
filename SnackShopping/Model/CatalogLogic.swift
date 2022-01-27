import Foundation

enum CatalogLogic {
    static func filter(
        _ snacks: [Snack],
        query: String = "",
        category: String = "All",
        sort: String = "name",
        savedIDs: Set<String> = []
    ) -> [Snack] {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let list = snacks.filter { snack in
            let haystack = "\(snack.name) \(snack.blurb) \(snack.ingredients.joined(separator: " "))".lowercased()
            let queryOK = needle.isEmpty || haystack.contains(needle)
            if category == "Quick" {
                return (snack.prepMinutes ?? 99) <= 20 && queryOK
            }
            if category == "Top" {
                return (snack.rating ?? 0) >= 4.5 && queryOK
            }
            let categoryOK = category == "All"
                || snack.category == category
                || (category == "Saved" && savedIDs.contains(snack.id))
            return categoryOK && queryOK
        }
        return list.sorted { lhs, rhs in
            if sort == "price" {
                if lhs.price == rhs.price { return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending }
                return lhs.price < rhs.price
            }
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
    }

    static func recommend(_ snacks: [Snack], recentIDs: [String]) -> [Snack] {
        let byID = Dictionary(uniqueKeysWithValues: snacks.map { ($0.id, $0) })
        let recent = recentIDs.compactMap { byID[$0] }
        let more: [Snack]
        if let lead = recent.first {
            more = snacks.filter { $0.category == lead.category && !recentIDs.contains($0.id) }
        } else {
            more = []
        }
        var picked: [Snack] = []
        var seen = Set<String>()
        for snack in recent + more {
            if seen.insert(snack.id).inserted {
                picked.append(snack)
            }
        }
        return Array(picked.prefix(8))
    }
}

enum PriceCaption {
    static func text(for snack: Snack) -> String {
        if snack.priceSource == "sample" {
            return "Sample counter price."
        }
        if snack.priceSource == "open-food-facts" {
            return "Shelf price from Open Food Facts for “\(snack.priceLabel)”."
        }
        if snack.priceLabel.compare(snack.name, options: .caseInsensitive) == .orderedSame {
            return "Grocery price from DummyJSON."
        }
        return "Market price from DummyJSON for “\(snack.priceLabel)”."
    }
}

enum Blurb {
    static func short(_ text: String, limit: Int = 110) -> String {
        let clean = text.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard clean.count > limit, limit > 3 else { return clean }
        let end = clean.index(clean.startIndex, offsetBy: limit - 3)
        return String(clean[..<end]).trimmingCharacters(in: .whitespaces) + "…"
    }
}
