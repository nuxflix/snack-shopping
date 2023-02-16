import Combine
import Foundation

@MainActor
final class CatalogStore: ObservableObject {
    enum Status: Equatable {
        case loading
        case ready
        case failed
    }

    @Published private(set) var snacks: [Snack] = SampleMenu.all
    @Published private(set) var status: Status = .ready
    @Published private(set) var message: String?
    @Published private(set) var usingSample = true
    @Published private(set) var recentIDs: [String] = []

    private let recentKey = "snack-shopping-recent"

    init(autoload: Bool = true) {
        recentIDs = UserDefaults.standard.stringArray(forKey: recentKey) ?? []
    }

    func snack(id: String) -> Snack? {
        snacks.first { $0.id == id }
    }

    func remember(_ id: String) {
        recentIDs.removeAll { $0 == id }
        recentIDs.insert(id, at: 0)
        if recentIDs.count > 8 { recentIDs = Array(recentIDs.prefix(8)) }
        UserDefaults.standard.set(recentIDs, forKey: recentKey)
    }

    func reload(fresh: Bool) async {
        snacks = SampleMenu.all
        status = .ready
        usingSample = true
        message = nil
    }

    static func preview() -> CatalogStore {
        CatalogStore(autoload: false)
    }
}
