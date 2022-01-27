import Foundation

enum SampleMenu {
    static let all: [Snack] = [
        snack("cocoa-brownie", "Cocoa Brownie", "Sweet", 4.50, "🍪", "A warm square with a crackled top and a soft middle.", ["cocoa", "chocolate"], ["80g butter", "120g sugar", "2 eggs", "40g cocoa"], prep: 25, rating: 4.8),
        snack("lemon-tart", "Lemon Tart", "Sweet", 5.00, "🍋", "A short crust and a sharp lemon curd.", ["tart", "citrus"], ["1 crust", "3 lemons", "100g sugar", "2 eggs"], prep: 35, rating: 4.7),
        snack("peanut-cookie", "Peanut Cookie", "Sweet", 2.60, "🥜", "A thick cookie with a salted peanut center.", ["cookie", "peanut"], ["120g flour", "60g peanuts", "1 egg"], prep: 15, rating: 4.4),
        snack("berry-parfait", "Berry Parfait", "Sweet", 4.25, "🫐", "Yogurt, berries, and a crushed biscuit layer.", ["berry", "yogurt"], ["200g yogurt", "80g berries", "2 biscuits"], prep: 10, rating: 4.6),
        snack("cheese-twist", "Cheese Twist", "Savory", 3.10, "🧀", "Puff pastry rolled with sharp cheese.", ["pastry", "cheese"], ["1 sheet pastry", "60g cheese"], prep: 20, rating: 4.3),
        snack("sea-salt-chips", "Sea Salt Chips", "Savory", 2.75, "🥔", "Crisp chips finished with flaky salt.", ["potato", "salt"], ["2 potatoes", "salt"], prep: 15, rating: 4.1),
        snack("tomato-cup", "Tomato Cup", "Savory", 2.90, "🍅", "A baked tomato cup with herbs and crumbs.", ["tomato", "herb"], ["4 tomatoes", "herbs", "20g crumbs"], prep: 18, rating: 4.2),
        snack("olive-bun", "Olive Bun", "Savory", 3.00, "🫒", "A soft bun studded with chopped olives.", ["bread", "olive"], ["200g flour", "40g olives"], prep: 30, rating: 4.0),
        snack("honey-granola", "Honey Granola", "Fresh", 3.25, "🍯", "Oats toasted with honey and seeds.", ["oat", "honey"], ["150g oats", "30g honey", "20g seeds"], prep: 20, rating: 4.5),
        snack("mango-lassi", "Mango Lassi", "Fresh", 3.80, "🥭", "A cold mango and yogurt drink.", ["mango", "yogurt"], ["1 mango", "150g yogurt"], prep: 8, rating: 4.7),
        snack("cold-brew", "Cold Brew", "Fresh", 3.40, "☕️", "Coffee steeped overnight and poured over ice.", ["coffee"], ["30g coffee", "300ml water"], prep: 5, rating: 4.6),
        snack("market-honey", "Honey Jar", "Market", 6.99, "🛒", "A grocery price from the counter list.", ["honey", "market"], [], rating: nil),
        snack("market-berry", "Strawberry", "Market", 3.99, "🛒", "A punnet from the market shelf.", ["fruit", "market"], [], rating: nil),
        snack("market-eggs", "Eggs", "Market", 2.99, "🛒", "A dozen eggs from the market shelf.", ["eggs", "market"], [], rating: nil)
    ]

    private static func snack(
        _ id: String,
        _ name: String,
        _ category: String,
        _ price: Double,
        _ emoji: String,
        _ blurb: String,
        _ tags: [String],
        _ ingredients: [String],
        prep: Int? = nil,
        rating: Double? = nil
    ) -> Snack {
        Snack(
            id: id,
            name: name,
            category: category,
            price: price,
            emoji: emoji,
            blurb: blurb,
            tags: tags,
            ingredients: ingredients,
            prepMinutes: prep,
            imageURL: nil,
            rating: rating,
            area: nil,
            priceSource: "sample",
            priceLabel: name
        )
    }
}
