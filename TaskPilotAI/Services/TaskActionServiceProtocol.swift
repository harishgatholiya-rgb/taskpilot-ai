import Foundation

/// Status-changing mutations on a task (complete, reopen, archive, pin,
/// delete). Kept separate from `TaskRepositoryProtocol` because these carry
/// business rules — e.g. completing a repeating task spawns its next
/// occurrence — whereas the repository is pure CRUD persistence.
@MainActor
protocol TaskActionServiceProtocol {
    @discardableResult
    func complete(_ task: TaskItem) throws -> TaskItem?

    func reopen(_ task: TaskItem) throws
    func archive(_ task: TaskItem) throws
    func unarchive(_ task: TaskItem) throws
    func togglePin(_ task: TaskItem) throws
    func delete(_ task: TaskItem) throws
}
