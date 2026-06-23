import Foundation

protocol PersistenceProviding {
    func load() -> PersistedState
    func save(_ state: PersistedState)
}

final class UserDefaultsPersistence: PersistenceProviding {
    private let defaults: UserDefaults
    private let key = "glowmate.persistedState.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> PersistedState {
        guard let data = defaults.data(forKey: key) else {
            return .empty
        }
        return (try? JSONDecoder().decode(PersistedState.self, from: data)) ?? .empty
    }

    func save(_ state: PersistedState) {
        guard let data = try? JSONEncoder().encode(state) else {
            return
        }
        defaults.set(data, forKey: key)
    }
}

final class MemoryPersistence: PersistenceProviding {
    private var state: PersistedState

    init(state: PersistedState) {
        self.state = state
    }

    func load() -> PersistedState {
        state
    }

    func save(_ state: PersistedState) {
        self.state = state
    }
}
