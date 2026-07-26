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
    let notificationService: NotificationServiceProtocol
    let hourlySummaryScheduler: HourlySummarySchedulerProtocol

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        let repository = SwiftDataTaskRepository(modelContext: modelContainer.mainContext)
        self.taskRepository = repository
        let prioritization = RuleBasedTaskPrioritizationService()
        self.prioritizationService = prioritization
        let notifications = LocalNotificationService()
        self.notificationService = notifications
        self.taskActionService = TaskActionService(taskRepository: repository, notificationService: notifications)
        self.hourlySummaryScheduler = HourlySummaryScheduler(
            taskRepository: repository,
            prioritizationService: prioritization,
            notificationService: notifications
        )
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
            taskActionService: taskActionService,
            hourlySummaryScheduler: hourlySummaryScheduler
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
        TaskFormViewModel(taskRepository: taskRepository, notificationService: notificationService, editingTask: task)
    }

    func makeTaskDetailViewModel(task: TaskItem) -> TaskDetailViewModel {
        TaskDetailViewModel(task: task, taskActionService: taskActionService)
    }
}
