import Foundation

/// Persistence boundary for `TaskItem`. ViewModels depend on this protocol,
/// never on SwiftData directly, so they stay testable with an in-memory fake.
@MainActor
protocol TaskRepositoryProtocol: AnyObject {
    func fetchAll() throws -> [TaskItem]
    func fetchActive() throws -> [TaskItem]
    func fetchArchived() throws -> [TaskItem]
    func fetch(id: UUID) throws -> TaskItem?

    @discardableResult
    func create(_ task: TaskItem) throws -> TaskItem

    func update(_ task: TaskItem) throws
    func delete(_ task: TaskItem) throws
}
