import Foundation

#if DEBUG
/// In-memory `TaskRepositoryProtocol` conformance for SwiftUI previews and
/// unit tests, so neither needs a real SwiftData `ModelContainer`.
@MainActor
final class InMemoryTaskRepository: TaskRepositoryProtocol {
    private var storage: [UUID: TaskItem]

    init(seed: [TaskItem] = []) {
        storage = Dictionary(uniqueKeysWithValues: seed.map { ($0.id, $0) })
    }

    func fetchAll() throws -> [TaskItem] {
        storage.values.sorted { $0.createdAt > $1.createdAt }
    }

    func fetchActive() throws -> [TaskItem] {
        try fetchAll().filter { $0.status == .active }
    }

    func fetchArchived() throws -> [TaskItem] {
        try fetchAll().filter { $0.status == .archived }
    }

    func fetch(id: UUID) throws -> TaskItem? {
        storage[id]
    }

    @discardableResult
    func create(_ task: TaskItem) throws -> TaskItem {
        storage[task.id] = task
        return task
    }

    func update(_ task: TaskItem) throws {
        task.updatedAt = .now
        storage[task.id] = task
    }

    func delete(_ task: TaskItem) throws {
        storage.removeValue(forKey: task.id)
    }
}
#endif
