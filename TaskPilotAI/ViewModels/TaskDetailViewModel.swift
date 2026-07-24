import Foundation
import Observation

@MainActor
@Observable
final class TaskDetailViewModel {
    private(set) var task: TaskItem
    private(set) var errorMessage: String?
    private(set) var wasDeleted = false

    private let taskActionService: TaskActionServiceProtocol

    init(task: TaskItem, taskActionService: TaskActionServiceProtocol) {
        self.task = task
        self.taskActionService = taskActionService
    }

    func toggleComplete() {
        perform {
            if task.status == .completed {
                try taskActionService.reopen(task)
            } else {
                try taskActionService.complete(task)
            }
        }
    }

    func toggleArchive() {
        perform {
            if task.status == .archived {
                try taskActionService.unarchive(task)
            } else {
                try taskActionService.archive(task)
            }
        }
    }

    func togglePin() {
        perform {
            try taskActionService.togglePin(task)
        }
    }

    func delete() {
        perform {
            try taskActionService.delete(task)
            wasDeleted = true
        }
    }

    func dismissError() {
        errorMessage = nil
    }

    private func perform(_ action: () throws -> Void) {
        do {
            try action()
            errorMessage = nil
        } catch {
            errorMessage = "Couldn't update \"\(task.title)\". Please try again."
        }
    }
}
