import Testing
import Foundation
@testable import TaskPilotAI

@MainActor
struct TaskFormViewModelTests {
    @Test func saveIsDisabledUntilTitleIsProvided() {
        let viewModel = TaskFormViewModel(taskRepository: InMemoryTaskRepository(), notificationService: NoOpNotificationService())

        #expect(viewModel.isSaveDisabled)

        viewModel.title = "   "
        #expect(viewModel.isSaveDisabled)

        viewModel.title = "Write the report"
        #expect(!viewModel.isSaveDisabled)
    }

    @Test func savingNewTaskCreatesItInRepository() throws {
        let repository = InMemoryTaskRepository()
        let viewModel = TaskFormViewModel(taskRepository: repository, notificationService: NoOpNotificationService())
        viewModel.title = "Call the plumber"
        viewModel.priority = .high
        viewModel.estimatedMinutesText = "20"

        let didSave = viewModel.save()

        #expect(didSave)
        let stored = try repository.fetchAll()
        #expect(stored.count == 1)
        #expect(stored.first?.title == "Call the plumber")
        #expect(stored.first?.priority == .high)
        #expect(stored.first?.estimatedMinutes == 20)
    }

    @Test func savingExistingTaskUpdatesInPlaceRatherThanDuplicating() throws {
        let repository = InMemoryTaskRepository()
        let existing = try repository.create(TaskItem(title: "Draft memo", priority: .low))
        let viewModel = TaskFormViewModel(taskRepository: repository, notificationService: NoOpNotificationService(), editingTask: existing)

        viewModel.title = "Finalize memo"
        viewModel.priority = .urgent
        let didSave = viewModel.save()

        #expect(didSave)
        let stored = try repository.fetchAll()
        #expect(stored.count == 1)
        #expect(stored.first?.title == "Finalize memo")
        #expect(stored.first?.priority == .urgent)
    }

    @Test func commitTagDraftAddsTrimmedTagAndPreventsDuplicates() {
        let viewModel = TaskFormViewModel(taskRepository: InMemoryTaskRepository(), notificationService: NoOpNotificationService())

        viewModel.tagDraft = "  urgent  "
        viewModel.commitTagDraft()
        viewModel.tagDraft = "URGENT"
        viewModel.commitTagDraft()

        #expect(viewModel.tags == ["urgent"])
    }

    @Test func clearingDueDateAlsoClearsDueTimeOnSave() throws {
        let repository = InMemoryTaskRepository()
        let viewModel = TaskFormViewModel(taskRepository: repository, notificationService: NoOpNotificationService())
        viewModel.title = "No due date task"
        viewModel.hasDueDate = false
        viewModel.hasDueTime = true

        #expect(viewModel.save())

        let stored = try repository.fetchAll().first
        #expect(stored?.dueDate == nil)
        #expect(stored?.hasDueTime == false)
    }
}
