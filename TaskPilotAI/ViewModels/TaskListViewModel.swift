import Foundation
import Observation

@MainActor
@Observable
final class TaskListViewModel {
    enum StatusFilter: String, CaseIterable, Identifiable, Hashable {
        case active = "Active"
        case completed = "Completed"
        case archived = "Archived"

        var id: String { rawValue }
    }

    enum SortOption: String, CaseIterable, Identifiable, Hashable {
        case priority = "Priority"
        case dueDate = "Due Date"
        case dateCreated = "Date Created"

        var id: String { rawValue }
    }

    var statusFilter: StatusFilter = .active {
        didSet { applyFilterAndSort() }
    }

    var sortOption: SortOption = .priority {
        didSet { applyFilterAndSort() }
    }

    var searchText: String = "" {
        didSet { applyFilterAndSort() }
    }

    var selectedCategory: TaskCategory? {
        didSet { applyFilterAndSort() }
    }

    private(set) var displayedTasks: [TaskItem] = []
    private(set) var errorMessage: String?

    private var allTasks: [TaskItem] = []

    private let taskRepository: TaskRepositoryProtocol
    private let prioritizationService: TaskPrioritizationServiceProtocol
    private let taskActionService: TaskActionServiceProtocol

    init(
        taskRepository: TaskRepositoryProtocol,
        prioritizationService: TaskPrioritizationServiceProtocol,
        taskActionService: TaskActionServiceProtocol
    ) {
        self.taskRepository = taskRepository
        self.prioritizationService = prioritizationService
        self.taskActionService = taskActionService
    }

    func refresh() {
        do {
            allTasks = try taskRepository.fetchAll()
            errorMessage = nil
            applyFilterAndSort()
        } catch {
            errorMessage = "Couldn't load your tasks. Pull to refresh to try again."
        }
    }

    func signals(for task: TaskItem) -> TaskSignals {
        prioritizationService.signals(for: task, now: .now)
    }

    func complete(_ task: TaskItem) {
        perform(actionName: "complete \"\(task.title)\"") {
            try taskActionService.complete(task)
        }
    }

    func reopen(_ task: TaskItem) {
        perform(actionName: "reopen \"\(task.title)\"") {
            try taskActionService.reopen(task)
        }
    }

    func archive(_ task: TaskItem) {
        perform(actionName: "archive \"\(task.title)\"") {
            try taskActionService.archive(task)
        }
    }

    func unarchive(_ task: TaskItem) {
        perform(actionName: "restore \"\(task.title)\"") {
            try taskActionService.unarchive(task)
        }
    }

    func togglePin(_ task: TaskItem) {
        perform(actionName: "update \"\(task.title)\"") {
            try taskActionService.togglePin(task)
        }
    }

    func delete(_ task: TaskItem) {
        perform(actionName: "delete \"\(task.title)\"") {
            try taskActionService.delete(task)
        }
    }

    func dismissError() {
        errorMessage = nil
    }

    // MARK: - Private

    private func perform(actionName: String, _ action: () throws -> Void) {
        do {
            try action()
            refresh()
        } catch {
            errorMessage = "Couldn't \(actionName). Please try again."
        }
    }

    private func applyFilterAndSort() {
        var filtered = allTasks.filter { task in
            switch statusFilter {
            case .active: task.status == .active
            case .completed: task.status == .completed
            case .archived: task.status == .archived
            }
        }

        if let selectedCategory {
            filtered = filtered.filter { $0.category == selectedCategory }
        }

        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedSearch.isEmpty {
            filtered = filtered.filter { task in
                task.title.localizedCaseInsensitiveContains(trimmedSearch)
                    || task.notes.localizedCaseInsensitiveContains(trimmedSearch)
                    || task.tags.contains { $0.localizedCaseInsensitiveContains(trimmedSearch) }
            }
        }

        displayedTasks = sort(filtered)
    }

    private func sort(_ tasks: [TaskItem]) -> [TaskItem] {
        switch sortOption {
        case .priority:
            tasks.sorted { lhs, rhs in
                if lhs.priority != rhs.priority { return lhs.priority > rhs.priority }
                return (lhs.dueDate ?? .distantFuture) < (rhs.dueDate ?? .distantFuture)
            }
        case .dueDate:
            tasks.sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
        case .dateCreated:
            tasks.sorted { $0.createdAt > $1.createdAt }
        }
    }
}
