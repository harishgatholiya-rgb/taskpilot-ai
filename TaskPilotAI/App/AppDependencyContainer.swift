import Foundation
import SwiftData

/// Composition root. Owns the SwiftData stack and hands out repositories,
/// services, and view models so views never instantiate concrete types
/// directly — everything they depend on is a protocol.
@MainActor
final class AppDependencyContainer {
    let modelContainer: ModelContainer
    let taskRepository: TaskRepositoryProtocol
    let prioritizationService: TaskPrioritizationServiceProtocol
    let taskActionService: TaskActionServiceProtocol

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        let repository = SwiftDataTaskRepository(modelContext: modelContainer.mainContext)
        self.taskRepository = repository
        self.prioritizationService = RuleBasedTaskPrioritizationService()
        self.taskActionService = TaskActionService(taskRepository: repository)
    }

    static func makeProductionModelContainer() throws -> ModelContainer {
        let schema = Schema([TaskItem.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    // MARK: - View model factories

    func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel(
            taskRepository: taskRepository,
            prioritizationService: prioritizationService,
            taskActionService: taskActionService
        )
    }

    func makeTaskListViewModel() -> TaskListViewModel {
        TaskListViewModel(
            taskRepository: taskRepository,
            prioritizationService: prioritizationService,
            taskActionService: taskActionService
        )
    }

    func makeTaskFormViewModel(editing task: TaskItem? = nil) -> TaskFormViewModel {
        TaskFormViewModel(taskRepository: taskRepository, editingTask: task)
    }

    func makeTaskDetailViewModel(task: TaskItem) -> TaskDetailViewModel {
        TaskDetailViewModel(task: task, taskActionService: taskActionService)
    }
}
