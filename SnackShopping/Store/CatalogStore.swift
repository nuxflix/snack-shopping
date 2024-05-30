import Combine
import Foundation

@MainActor
final class CatalogStore: ObservableObject {
    enum Status: Equatable {
        case loading
        case ready
        case failed
    }

    @Published private(set) var snacks: [Snack] = []
    @Published private(set) var status: Status = .loading
    @Published private(set) var message: String?
    @Published private(set) var usingSample = false
    @Published private(set) var recentIDs: [String] = []

    private let recentKey = "snack-shopping-recent"
    private let autoload: Bool

    init(autoload: Bool = true) {
        self.autoload = autoload
        recentIDs = Self.readRecent(recentKey)
        if autoload {
            Task { await reload(fresh: false) }
        }
    }

    func snack(id: String) -> Snack? {
        snacks.first { $0.id == id }
    }

    func remember(_ id: String) {
        recentIDs.removeAll { $0 == id }
        recentIDs.insert(id, at: 0)
        if recentIDs.count > 8 {
            recentIDs = Array(recentIDs.prefix(8))
        }
        UserDefaults.standard.set(recentIDs, forKey: recentKey)
    }

    func reload(fresh: Bool) async {
        if fresh { CatalogLoader.clearCache() }
        status = .loading
        message = nil
        do {
            let loaded = try await CatalogLoader.load()
            snacks = loaded
            usingSample = false
            status = .ready
        } catch {
            if snacks.isEmpty {
                snacks = SampleMenu.all
                usingSample = true
            }
            message = error.localizedDescription
            status = snacks.isEmpty ? .failed : .ready
        }
    }

    static func preview() -> CatalogStore {
        let store = CatalogStore(autoload: false)
        store.snacks = SampleMenu.all
        store.status = .ready
        store.usingSample = true
        return store
    }

    private static func readRecent(_ key: String) -> [String] {
        UserDefaults.standard.stringArray(forKey: key) ?? []
    }
}
