import XCTest
@testable import SnackShopping

final class ShopLogicTests: XCTestCase {
    func testDeliveryIsFreeOnceTheBagReachesTheThreshold() {
        XCTAssertEqual(Delivery.fee(for: 0), 0)
        XCTAssertEqual(Delivery.fee(for: 10), 3.5)
        XCTAssertEqual(Delivery.fee(for: 35), 0)
        XCTAssertEqual(Delivery.fee(for: 40), 0)
    }

    func testMissingSnacksDoNotChangeTheTotal() {
        let total = CartMath.subtotal(prices: ["cocoa": 4.5], quantities: ["cocoa": 2, "gone": 3])
        XCTAssertEqual(total, 9)
    }

    func testRecommendationsStayOnTheShelfYouOpened() {
        let snacks = [
            sample("a", "Apple cake", "Sweet"),
            sample("b", "Pancakes", "Sweet"),
            sample("c", "Chips", "Savory")
        ]
        let picked = CatalogLogic.recommend(snacks, recentIDs: ["a"])
        XCTAssertEqual(picked.map(\.id), ["a", "b"])
    }

    func testQuantityStaysInsideTheCounterLimit() {
        XCTAssertEqual(Qty.clamp(0), 1)
        XCTAssertEqual(Qty.clamp(0, allowZero: true), 0)
        XCTAssertEqual(Qty.clamp(24), 20)
    }

    private func sample(_ id: String, _ name: String, _ category: String) -> Snack {
        Snack(
            id: id,
            name: name,
            category: category,
            price: 1,
            emoji: "🍪",
            blurb: "",
            tags: [],
            ingredients: [],
            prepMinutes: nil,
            imageURL: nil,
            rating: nil,
            area: nil,
            priceSource: "sample",
            priceLabel: name
        )
    }
}
