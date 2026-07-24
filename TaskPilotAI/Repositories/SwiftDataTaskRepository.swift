import Foundation
import SwiftData

@MainActor
final class SwiftDataTaskRepository: TaskRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() throws -> [TaskItem] {
        let descriptor = FetchDescriptor<TaskItem>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchActive() throws -> [TaskItem] {
        let activeRaw = TaskStatus.active.rawValue
        let descriptor = FetchDescriptor<TaskItem>(
            predicate: #Predicate { $0.statusRaw == activeRaw },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchArchived() throws -> [TaskItem] {
        let archivedRaw = TaskStatus.archived.rawValue
        let descriptor = FetchDescriptor<TaskItem>(
            predicate: #Predicate { $0.statusRaw == archivedRaw },
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetch(id: UUID) throws -> TaskItem? {
        var descriptor = FetchDescriptor<TaskItem>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    @discardableResult
    func create(_ task: TaskItem) throws -> TaskItem {
        modelContext.insert(task)
        try modelContext.save()
        return task
    }

    func update(_ task: TaskItem) throws {
        task.updatedAt = .now
        try modelContext.save()
    }

    func delete(_ task: TaskItem) throws {
        modelContext.delete(task)
        try modelContext.save()
    }
}
