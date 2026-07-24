import Foundation
import Observation

/// Backs both the "New Task" and "Edit Task" screens. Editing mode is
/// determined by whether an existing `TaskItem` was passed in at init.
@MainActor
@Observable
final class TaskFormViewModel {
    var title: String = ""
    var notes: String = ""
    var tags: [String] = []
    var tagDraft: String = ""
    var priority: TaskPriority = .medium
    var category: TaskCategory = .other
    var repeatRule: RepeatRule = .none
    var hasDueDate: Bool = false
    var dueDate: Date = .now
    var hasDueTime: Bool = false
    var estimatedMinutesText: String = ""
    var isWaitingOnOthers: Bool = false
    var isPinned: Bool = false

    private(set) var errorMessage: String?

    private let taskRepository: TaskRepositoryProtocol
    private let editingTask: TaskItem?

    var isEditing: Bool { editingTask != nil }
    var navigationTitle: String { isEditing ? "Edit Task" : "New Task" }

    var isSaveDisabled: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(taskRepository: TaskRepositoryProtocol, editingTask: TaskItem? = nil) {
        self.taskRepository = taskRepository
        self.editingTask = editingTask

        guard let editingTask else { return }
        title = editingTask.title
        notes = editingTask.notes
        tags = editingTask.tags
        priority = editingTask.priority
        category = editingTask.category
        repeatRule = editingTask.repeatRule
        hasDueDate = editingTask.dueDate != nil
        dueDate = editingTask.dueDate ?? .now
        hasDueTime = editingTask.hasDueTime
        estimatedMinutesText = editingTask.estimatedMinutes.map(String.init) ?? ""
        isWaitingOnOthers = editingTask.isWaitingOnOthers
        isPinned = editingTask.isPinned
    }

    func commitTagDraft() {
        let candidate = tagDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        tagDraft = ""
        guard !candidate.isEmpty, !tags.contains(where: { $0.caseInsensitiveCompare(candidate) == .orderedSame }) else {
            return
        }
        tags.append(candidate)
    }

    func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }

    @discardableResult
    func save() -> Bool {
        commitTagDraft()

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            errorMessage = "Give this task a title."
            return false
        }

        let estimatedMinutes = Int(estimatedMinutesText.trimmingCharacters(in: .whitespacesAndNewlines))
        let resolvedDueDate = hasDueDate ? dueDate : nil
        let resolvedHasDueTime = hasDueDate && hasDueTime

        do {
            if let editingTask {
                editingTask.title = trimmedTitle
                editingTask.notes = notes
                editingTask.tags = tags
                editingTask.priority = priority
                editingTask.category = category
                editingTask.repeatRule = repeatRule
                editingTask.dueDate = resolvedDueDate
                editingTask.hasDueTime = resolvedHasDueTime
                editingTask.estimatedMinutes = estimatedMinutes
                editingTask.isWaitingOnOthers = isWaitingOnOthers
                editingTask.isPinned = isPinned
                try taskRepository.update(editingTask)
            } else {
                let newTask = TaskItem(
                    title: trimmedTitle,
                    notes: notes,
                    tags: tags,
                    priority: priority,
                    category: category,
                    repeatRule: repeatRule,
                    dueDate: resolvedDueDate,
                    hasDueTime: resolvedHasDueTime,
                    estimatedMinutes: estimatedMinutes,
                    isWaitingOnOthers: isWaitingOnOthers,
                    isPinned: isPinned
                )
                try taskRepository.create(newTask)
            }
            errorMessage = nil
            return true
        } catch {
            errorMessage = "Couldn't save this task. Please try again."
            return false
        }
    }
}
