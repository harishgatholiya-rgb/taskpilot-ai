import Foundation

@MainActor
final class TaskActionService: TaskActionServiceProtocol {
    private let taskRepository: TaskRepositoryProtocol

    init(taskRepository: TaskRepositoryProtocol) {
        self.taskRepository = taskRepository
    }

    /// Marks `task` complete and, if it repeats, creates the next
    /// occurrence. Returns the newly-created occurrence, if any.
    @discardableResult
    func complete(_ task: TaskItem) throws -> TaskItem? {
        let completionDate = Date.now
        task.status = .completed
        task.completedAt = completionDate
        try taskRepository.update(task)

        guard task.repeatRule != .none else { return nil }
        let anchorDate = task.dueDate ?? completionDate
        guard let nextDueDate = task.repeatRule.nextOccurrence(after: anchorDate) else { return nil }

        let nextOccurrence = TaskItem(
            title: task.title,
            notes: task.notes,
            tags: task.tags,
            priority: task.priority,
            category: task.category,
            repeatRule: task.repeatRule,
            dueDate: nextDueDate,
            hasDueTime: task.hasDueTime,
            estimatedMinutes: task.estimatedMinutes,
            isPinned: task.isPinned,
            repeatedFromID: task.id
        )
        return try taskRepository.create(nextOccurrence)
    }

    func reopen(_ task: TaskItem) throws {
        task.status = .active
        task.completedAt = nil
        try taskRepository.update(task)
    }

    func archive(_ task: TaskItem) throws {
        task.status = .archived
        try taskRepository.update(task)
    }

    func unarchive(_ task: TaskItem) throws {
        task.status = .active
        try taskRepository.update(task)
    }

    func togglePin(_ task: TaskItem) throws {
        task.isPinned.toggle()
        try taskRepository.update(task)
    }

    func delete(_ task: TaskItem) throws {
        try taskRepository.delete(task)
    }
}
