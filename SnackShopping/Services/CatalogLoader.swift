import Foundation

enum CatalogError: LocalizedError {
    case empty

    var errorDescription: String? {
        switch self {
        case .empty:
            return "The menu feeds came back empty."
        }
    }
}

enum CatalogLoader {
    private static let cacheName = "snack-shopping-catalog.json"
    private static let cacheLifetime: TimeInterval = 30 * 60
    private static let mealTerms = ["cake", "brownie", "pancake", "chocolate", "cookie", "pie", "pudding", "donut", "cheesecake", "tart"]
    private static let recipeTypes: Set<String> = ["snack", "snacks", "dessert", "appetizer", "breakfast", "side dish"]

    static func load() async throws -> [Snack] {
        if let cached = readCache() {
            return cached
        }
        async let meals = fetchMeals()
        async let recipes = fetchRecipes()
        async let groceries = fetchGroceries()
        async let offers = fetchOffers()
        async let rates = fetchRates()
        let snacks = assemble(
            meals: await meals,
            recipes: await recipes,
            groceries: await groceries,
            offers: await offers,
            rates: await rates
        )
        if snacks.isEmpty {
            throw CatalogError.empty
        }
        writeCache(snacks)
        return snacks
    }

    static func clearCache() {
        guard let url = cacheURL() else { return }
        try? FileManager.default.removeItem(at: url)
    }

    static func assemble(
        meals: [MealRecord],
        recipes: [RecipeRecord],
        groceries: [GroceryRecord],
        offers: [PriceOffer],
        rates: [String: Double]
    ) -> [Snack] {
        let anchors = groceries
            .filter { $0.title.range(of: "cat food|dog food|tissue", options: [.regularExpression, .caseInsensitive]) == nil }
            .map { PriceAnchor(title: $0.title, price: $0.price) }
        var snacks: [Snack] = []
        var seen = Set<String>()

        for meal in meals {
            let key = meal.name.lowercased()
            if seen.contains(key) { continue }
            seen.insert(key)
            let tags = meal.tags
            let category = shelf(for: meal.category, tags: tags, market: false)
            let price = PriceMatch.choose(name: meal.name, category: meal.category.isEmpty ? category : meal.category, offers: offers, anchors: anchors, unitsPerUsd: rates)
            snacks.append(Snack(
                id: "meal-\(meal.id)",
                name: meal.name,
                category: category,
                price: price.amount,
                emoji: emoji(for: category),
                blurb: blurb(meal.instructions, fallback: "A kitchen recipe with a photo from TheMealDB."),
                tags: tags,
                ingredients: meal.ingredients,
                prepMinutes: nil,
                imageURL: meal.image,
                rating: nil,
                area: meal.area,
                priceSource: price.source,
                priceLabel: price.label
            ))
        }

        for recipe in recipes where recipeOK(recipe) {
            let key = recipe.name.lowercased()
            if seen.contains(key) { continue }
            seen.insert(key)
            let tags = recipe.tags + recipe.mealTypes
            let category = shelf(for: recipe.cuisine, tags: tags, market: false)
            let price = PriceMatch.choose(name: recipe.name, category: category, offers: offers, anchors: anchors, unitsPerUsd: rates)
            let fallback = recipe.ingredients.prefix(4).joined(separator: ", ")
            snacks.append(Snack(
                id: "recipe-\(recipe.id)",
                name: recipe.name,
                category: category,
                price: price.amount,
                emoji: emoji(for: category),
                blurb: blurb(recipe.instructions.joined(separator: " "), fallback: fallback.isEmpty ? "A recipe from the public recipe feed." : fallback),
                tags: tags,
                ingredients: recipe.ingredients,
                prepMinutes: recipe.prepMinutes,
                imageURL: recipe.image,
                rating: recipe.rating,
                area: recipe.cuisine,
                priceSource: price.source,
                priceLabel: price.label
            ))
        }

        for product in groceries {
            if product.title.range(of: "cat food|dog food|tissue", options: [.regularExpression, .caseInsensitive]) != nil {
                continue
            }
            let price = PriceMatch.choose(name: product.title, category: "Market", offers: offers, anchors: anchors, unitsPerUsd: rates, ownPrice: product.price)
            snacks.append(Snack(
                id: "market-\(product.id)",
                name: product.title,
                category: "Market",
                price: price.amount,
                emoji: "🛒",
                blurb: product.detail.isEmpty ? "A grocery price from the public product feed." : product.detail,
                tags: product.tags.isEmpty ? ["market"] : product.tags,
                ingredients: [],
                prepMinutes: nil,
                imageURL: product.image,
                rating: nil,
                area: nil,
                priceSource: "dummyjson",
                priceLabel: product.title
            ))
        }
        return snacks
    }

    static func shelf(for category: String, tags: [String], market: Bool) -> String {
        if market { return "Market" }
        let text = "\(category) \(tags.joined(separator: " "))".lowercased()
        if text.range(of: "dessert|sweet|cake|cookie|chocolate|pudding|brownie|donut|ice", options: .regularExpression) != nil {
            return "Sweet"
        }
        if text.range(of: "breakfast|beverage|smoothie|drink|juice|fruit", options: .regularExpression) != nil {
            return "Fresh"
        }
        return "Savory"
    }

    private static func emoji(for category: String) -> String {
        switch category {
        case "Sweet": return "🍪"
        case "Fresh": return "🍊"
        case "Market": return "🛒"
        default: return "🥙"
        }
    }

    private static func blurb(_ text: String, fallback: String) -> String {
        let clean = text.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if clean.isEmpty { return fallback }
        if clean.count > 220 {
            let end = clean.index(clean.startIndex, offsetBy: 217)
            return String(clean[..<end]) + "…"
        }
        return clean
    }

    private static func recipeOK(_ recipe: RecipeRecord) -> Bool {
        let name = recipe.name.lowercased()
        if name.range(of: "caipirinha|mojito|cocktail", options: .regularExpression) != nil { return false }
        if recipe.tags.contains(where: { $0.range(of: "cocktail|alcohol", options: [.regularExpression, .caseInsensitive]) != nil }) {
            return false
        }
        return recipe.mealTypes.contains { recipeTypes.contains($0.lowercased()) }
    }

    private static func fetchMeals() async -> [MealRecord] {
        var meals: [MealRecord] = []
        var seen = Set<String>()
        for term in mealTerms {
            guard meals.count < 24 else { break }
            guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/search.php?s=\(term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? term)"),
                  let payload = try? await fetchJSON(url),
                  let rows = payload["meals"] as? [[String: Any]] else { continue }
            for row in rows {
                guard let id = row["idMeal"] as? String, !seen.contains(id) else { continue }
                seen.insert(id)
                meals.append(MealRecord(json: row))
                if meals.count >= 24 { break }
            }
        }
        return meals
    }

    private static func fetchRecipes() async -> [RecipeRecord] {
        guard let url = URL(string: "https://dummyjson.com/recipes?limit=0"),
              let data = try? await fetchData(url),
              let box = try? JSONDecoder().decode(RecipeBox.self, from: data) else { return [] }
        return box.recipes
    }

    private static func fetchGroceries() async -> [GroceryRecord] {
        guard let url = URL(string: "https://dummyjson.com/products/category/groceries?limit=0"),
              let data = try? await fetchData(url),
              let box = try? JSONDecoder().decode(GroceryBox.self, from: data) else { return [] }
        return box.products
    }

    private static func fetchOffers() async -> [PriceOffer] {
        var offers: [PriceOffer] = []
        var page = 1
        while page <= 4 && offers.count < 80 {
            guard let url = URL(string: "https://prices.openfoodfacts.org/api/v1/prices?size=50&page=\(page)"),
                  let data = try? await fetchData(url),
                  let box = try? JSONDecoder().decode(PriceBox.self, from: data) else { break }
            for item in box.items ?? [] {
                let name = item.productName ?? item.product?.productName
                guard let name, let price = item.price, let currency = item.currency, price > 0 else { continue }
                offers.append(PriceOffer(name: name, price: price, currency: currency, source: "open-food-facts"))
            }
            page += 1
        }
        return offers
    }

    private static func fetchRates() async -> [String: Double] {
        guard let url = URL(string: "https://api.frankfurter.dev/v1/latest?from=USD"),
              let data = try? await fetchData(url),
              let box = try? JSONDecoder().decode(RateBox.self, from: data) else { return [:] }
        return box.rates ?? [:]
    }

    private static func fetchData(_ url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw CatalogError.empty
        }
        return data
    }

    private static func fetchJSON(_ url: URL) async throws -> [String: Any] {
        let data = try await fetchData(url)
        let object = try JSONSerialization.jsonObject(with: data)
        return object as? [String: Any] ?? [:]
    }

    private static func cacheURL() -> URL? {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?
            .appendingPathComponent(cacheName)
    }

    private static func readCache() -> [Snack]? {
        guard let url = cacheURL(),
              let data = try? Data(contentsOf: url),
              let box = try? JSONDecoder().decode(CacheBox.self, from: data),
              Date().timeIntervalSince(box.at) < cacheLifetime else { return nil }
        return box.snacks
    }

    private static func writeCache(_ snacks: [Snack]) {
        guard let url = cacheURL(),
              let data = try? JSONEncoder().encode(CacheBox(at: Date(), snacks: snacks)) else { return }
        try? data.write(to: url, options: .atomic)
    }
}

struct MealRecord {
    var id: String
    var name: String
    var category: String
    var area: String?
    var instructions: String
    var image: String?
    var tags: [String]
    var ingredients: [String]

    init(json: [String: Any]) {
        id = json["idMeal"] as? String ?? UUID().uuidString
        name = json["strMeal"] as? String ?? "Snack"
        category = json["strCategory"] as? String ?? ""
        let areaText = (json["strArea"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        area = areaText.isEmpty ? nil : areaText
        instructions = json["strInstructions"] as? String ?? ""
        let thumb = json["strMealThumb"] as? String
        image = thumb?.isEmpty == false ? thumb : nil
        let rawTags = (json["strTags"] as? String ?? "").split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        tags = ([category] + rawTags).filter { !$0.isEmpty }
        var items: [String] = []
        for index in 1...20 {
            let name = (json["strIngredient\(index)"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let measure = (json["strMeasure\(index)"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if name.isEmpty { continue }
            items.append(measure.isEmpty ? name : "\(measure) \(name)")
        }
        ingredients = items
    }
}

struct RecipeRecord: Decodable {
    var id: Int
    var name: String
    var image: String?
    var ingredients: [String]
    var instructions: [String]
    var mealTypes: [String]
    var tags: [String]
    var prepMinutes: Int?
    var cuisine: String?
    var rating: Double?

    enum CodingKeys: String, CodingKey {
        case id, name, image, ingredients, instructions, tags, cuisine, rating
        case mealTypes = "mealType"
        case prepMinutes = "prepTimeMinutes"
    }

    init(from decoder: Decoder) throws {
        let box = try decoder.container(keyedBy: CodingKeys.self)
        id = try box.decode(Int.self, forKey: .id)
        name = try box.decode(String.self, forKey: .name)
        image = try box.decodeIfPresent(String.self, forKey: .image)
        ingredients = try box.decodeIfPresent([String].self, forKey: .ingredients) ?? []
        instructions = try box.decodeIfPresent([String].self, forKey: .instructions) ?? []
        mealTypes = try box.decodeIfPresent([String].self, forKey: .mealTypes) ?? []
        tags = try box.decodeIfPresent([String].self, forKey: .tags) ?? []
        prepMinutes = try box.decodeIfPresent(Int.self, forKey: .prepMinutes)
        cuisine = try box.decodeIfPresent(String.self, forKey: .cuisine)
        rating = try box.decodeIfPresent(Double.self, forKey: .rating)
    }
}

struct GroceryRecord: Decodable {
    var id: Int
    var title: String
    var detail: String
    var price: Double
    var image: String?
    var tags: [String]

    enum CodingKeys: String, CodingKey {
        case id, title, price, tags
        case detail = "description"
        case image = "thumbnail"
    }

    init(from decoder: Decoder) throws {
        let box = try decoder.container(keyedBy: CodingKeys.self)
        id = try box.decode(Int.self, forKey: .id)
        title = try box.decode(String.self, forKey: .title)
        detail = try box.decodeIfPresent(String.self, forKey: .detail) ?? ""
        price = try box.decode(Double.self, forKey: .price)
        image = try box.decodeIfPresent(String.self, forKey: .image)
        tags = try box.decodeIfPresent([String].self, forKey: .tags) ?? []
    }
}

private struct RecipeBox: Decodable {
    var recipes: [RecipeRecord]
}

private struct GroceryBox: Decodable {
    var products: [GroceryRecord]
}

private struct PriceBox: Decodable {
    var items: [PriceRow]?
}

private struct PriceRow: Decodable {
    var price: Double?
    var currency: String?
    var productName: String?
    var product: Nested?

    struct Nested: Decodable {
        var productName: String?
        enum CodingKeys: String, CodingKey { case productName = "product_name" }
    }

    enum CodingKeys: String, CodingKey {
        case price, currency, product
        case productName = "product_name"
    }
}

private struct RateBox: Decodable {
    var rates: [String: Double]?
}

private struct CacheBox: Codable {
    var at: Date
    var snacks: [Snack]
}
