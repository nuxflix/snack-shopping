import Foundation

struct PriceOffer: Equatable {
    var name: String
    var price: Double
    var currency: String
    var source: String
}

struct PriceAnchor: Equatable {
    var title: String
    var price: Double
}

struct ChosenPrice: Equatable {
    var amount: Double
    var source: String
    var label: String
}

enum PriceMatch {
    private static let stop: Set<String> = ["with", "and", "the", "for", "from", "style", "classic", "fresh", "food", "snack"]

    static func tokenize(_ value: String) -> [String] {
        let folded = value.folding(options: .diacriticInsensitive, locale: Locale(identifier: "en_US_POSIX")).lowercased()
        return folded.split { character in
            !character.isLetter && !character.isNumber
        }.map(String.init).filter { token in
            token.count > 2 && !stop.contains(token)
        }
    }

    static func overlap(_ left: [String], _ right: [String]) -> Int {
        let exact = Set(right)
        let stems = Set(right.map { String($0.prefix(5)) })
        var score = 0
        for token in left {
            if exact.contains(token) || (token.count >= 5 && stems.contains(String(token.prefix(5)))) {
                score += 2
            }
        }
        return score
    }

    static func toUsd(amount: Double, currency: String, unitsPerUsd: [String: Double]) -> Double? {
        guard amount.isFinite, amount > 0 else { return nil }
        if currency == "USD" { return amount }
        guard let perUsd = unitsPerUsd[currency], perUsd != 0 else { return nil }
        return amount / perUsd
    }

    static func choose(
        name: String,
        category: String,
        offers: [PriceOffer],
        anchors: [PriceAnchor],
        unitsPerUsd: [String: Double],
        ownPrice: Double? = nil
    ) -> ChosenPrice {
        if let ownPrice {
            return ChosenPrice(amount: roundMoney(ownPrice), source: "dummyjson", label: name)
        }
        let tokens = tokenize("\(name) \(category)")
        var best: (score: Int, offer: PriceOffer)?
        for offer in offers {
            let score = overlap(tokens, tokenize(offer.name))
            if best == nil || score > best!.score {
                best = (score, offer)
            }
        }
        if let best, best.score >= 2, let usd = toUsd(amount: best.offer.price, currency: best.offer.currency, unitsPerUsd: unitsPerUsd), usd <= 40 {
            return ChosenPrice(amount: roundMoney(usd), source: "open-food-facts", label: best.offer.name)
        }
        if let anchor = anchorFor(name: name, category: category, anchors: anchors) {
            return ChosenPrice(amount: roundMoney(anchor.price), source: "dummyjson", label: anchor.title)
        }
        return ChosenPrice(amount: 0, source: "dummyjson", label: name)
    }

    private static func anchorFor(name: String, category: String, anchors: [PriceAnchor]) -> PriceAnchor? {
        let text = "\(name) \(category)".lowercased()
        let preferred: String
        if text.range(of: "cake|cookie|sweet|chocolate|brownie|ice|pudding|pie|donut|mochi|dessert", options: .regularExpression) != nil {
            preferred = "Ice Cream"
        } else if text.range(of: "coffee|tea", options: .regularExpression) != nil {
            preferred = "Nescafe Coffee"
        } else if text.range(of: "juice|smoothie|drink|lassi|beverage", options: .regularExpression) != nil {
            preferred = "Juice"
        } else if text.range(of: "apple|fruit|berry|mango|strawberry|citrus", options: .regularExpression) != nil {
            preferred = "Strawberry"
        } else if text.contains("honey") {
            preferred = "Honey Jar"
        } else {
            preferred = "Eggs"
        }
        return anchors.first { $0.title.compare(preferred, options: .caseInsensitive) == .orderedSame } ?? anchors.first
    }

    static func roundMoney(_ amount: Double) -> Double {
        (amount * 100).rounded() / 100
    }
}
