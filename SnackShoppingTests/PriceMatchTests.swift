import XCTest
@testable import SnackShopping

final class PriceMatchTests: XCTestCase {
    private let anchors = [
        PriceAnchor(title: "Ice Cream", price: 5.49),
        PriceAnchor(title: "Juice", price: 3.99),
        PriceAnchor(title: "Eggs", price: 2.99),
        PriceAnchor(title: "Strawberry", price: 3.99)
    ]

    func testChocolateWordsUseTheShelfPriceInDollars() {
        let chosen = PriceMatch.choose(
            name: "Chocolate Chip Cookies",
            category: "Dessert",
            offers: [PriceOffer(name: "Mousse liegeoise chocolat", price: 1.24, currency: "EUR", source: "open-food-facts")],
            anchors: anchors,
            unitsPerUsd: ["EUR": 0.9]
        )
        XCTAssertEqual(chosen.source, "open-food-facts")
        XCTAssertEqual(chosen.label, "Mousse liegeoise chocolat")
        XCTAssertEqual(chosen.amount, PriceMatch.roundMoney(1.24 / 0.9))
    }

    func testADessertWithoutAShelfMatchUsesIceCream() {
        let chosen = PriceMatch.choose(name: "Parkin Cake", category: "Dessert", offers: [], anchors: anchors, unitsPerUsd: ["EUR": 0.9])
        XCTAssertEqual(chosen.source, "dummyjson")
        XCTAssertEqual(chosen.label, "Ice Cream")
        XCTAssertEqual(chosen.amount, 5.49)
    }

    func testAGroceryKeepsItsOwnPrice() {
        let chosen = PriceMatch.choose(name: "Honey Jar", category: "Market", offers: [], anchors: anchors, unitsPerUsd: [:], ownPrice: 6.99)
        XCTAssertEqual(chosen.amount, 6.99)
        XCTAssertEqual(chosen.source, "dummyjson")
    }

    func testCurrencyConversionNeedsAKnownRate() {
        XCTAssertNil(PriceMatch.toUsd(amount: 2, currency: "EUR", unitsPerUsd: [:]))
        XCTAssertEqual(PriceMatch.toUsd(amount: 2, currency: "USD", unitsPerUsd: [:]), 2)
        XCTAssertGreaterThanOrEqual(
            PriceMatch.overlap(PriceMatch.tokenize("chocolat cake"), PriceMatch.tokenize("chocolate mousse")),
            1
        )
    }
}
