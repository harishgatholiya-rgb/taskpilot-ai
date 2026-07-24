import Testing
import Foundation
@testable import TaskPilotAI

@MainActor
struct TaskActionServiceTests {
    @Test func completeMarksTaskCompletedWithTimestamp() throws {
        let repository = InMemoryTaskRepository()
        let service = TaskActionService(taskRepository: repository)
        let task = try repository.create(TaskItem(title: "Ship it", priority: .high))

        try service.complete(task)

        #expect(task.status == .completed)
        #expect(task.completedAt != nil)
    }

    @Test func completingRepeatingTaskSpawnsNextOccurrence() throws {
        let repository = InMemoryTaskRepository()
        let service = TaskActionService(taskRepository: repository)
        let dueDate = Date(timeIntervalSince1970: 1_700_000_000)
        let task = try repository.create(TaskItem(
            title: "Water plants",
            repeatRule: .daily,
            dueDate: dueDate,
            hasDueTime: true
        ))

        let next = try service.complete(task)

        #expect(task.status == .completed)
        #expect(next != nil)
        #expect(next?.title == "Water plants")
        #expect(next?.repeatedFromID == task.id)
        #expect(next?.status == .active)
        if let nextDueDate = next?.dueDate {
            #expect(nextDueDate > dueDate)
        } else {
            Issue.record("Expected the spawned occurrence to have a due date")
        }
    }

    @Test func completingNonRepeatingTaskDoesNotSpawnAnything() throws {
        let repository = InMemoryTaskRepository()
        let service = TaskActionService(taskRepository: repository)
        let task = try repository.create(TaskItem(title: "One-off task"))

        let next = try service.complete(task)

        #expect(next == nil)
        #expect(try repository.fetchAll().count == 1)
    }

    @Test func archiveThenUnarchiveRestoresActiveStatus() throws {
        let repository = InMemoryTaskRepository()
        let service = TaskActionService(taskRepository: repository)
        let task = try repository.create(TaskItem(title: "Shelve me"))

        try service.archive(task)
        #expect(task.status == .archived)

        try service.unarchive(task)
        #expect(task.status == .active)
    }

    @Test func togglePinFlipsPinnedState() throws {
        let repository = InMemoryTaskRepository()
        let service = TaskActionService(taskRepository: repository)
        let task = try repository.create(TaskItem(title: "Pin me", isPinned: false))

        try service.togglePin(task)
        #expect(task.isPinned)

        try service.togglePin(task)
        #expect(!task.isPinned)
    }

    @Test func deleteRemovesTaskFromRepository() throws {
        let repository = InMemoryTaskRepository()
        let service = TaskActionService(taskRepository: repository)
        let task = try repository.create(TaskItem(title: "Remove me"))

        try service.delete(task)

        #expect(try repository.fetchAll().isEmpty)
    }
}
