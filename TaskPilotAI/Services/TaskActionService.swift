import Foundation

@MainActor
final class TaskActionService: TaskActionServiceProtocol {
    private let taskRepository: TaskRepositoryProtocol
    private let notificationService: NotificationServiceProtocol

    init(taskRepository: TaskRepositoryProtocol, notificationService: NotificationServiceProtocol) {
        self.taskRepository = taskRepository
        self.notificationService = notificationService
    }

    /// Marks `task` complete and, if it repeats, creates the next
    /// occurrence. Returns the newly-created occurrence, if any.
    @discardableResult
    func complete(_ task: TaskItem) throws -> TaskItem? {
        let completionDate = Date.now
        task.status = .completed
        task.completedAt = completionDate
        try taskRepository.update(task)
        notificationService.cancelReminder(for: task)

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
        let created = try taskRepository.create(nextOccurrence)
        notificationService.scheduleReminder(for: created)
        return created
    }

    func reopen(_ task: TaskItem) throws {
        task.status = .active
        task.completedAt = nil
        try taskRepository.update(task)
        notificationService.scheduleReminder(for: task)
    }

    func archive(_ task: TaskItem) throws {
        task.status = .archived
        try taskRepository.update(task)
        notificationService.cancelReminder(for: task)
    }

    func unarchive(_ task: TaskItem) throws {
        task.status = .active
        try taskRepository.update(task)
        notificationService.scheduleReminder(for: task)
    }

    func togglePin(_ task: TaskItem) throws {
        task.isPinned.toggle()
        try taskRepository.update(task)
    }

    func delete(_ task: TaskItem) throws {
        notificationService.cancelReminder(for: task)
        try taskRepository.delete(task)
    }
}
