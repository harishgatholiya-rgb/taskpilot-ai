import Foundation
import Observation

@MainActor
@Observable
final class DashboardViewModel {
    private(set) var nextTask: TaskItem?
    private(set) var todaysTasks: [TaskItem] = []
    private(set) var overdueTasks: [TaskItem] = []
    private(set) var upcomingTasks: [TaskItem] = []
    private(set) var pinnedTasks: [TaskItem] = []
    private(set) var completedTodayTasks: [TaskItem] = []
    private(set) var errorMessage: String?

    /// Fraction of today's work already done, for the progress ring.
    /// Today's work = tasks due today (or overdue) plus anything already
    /// completed today, so the ring still fills up on days with no due
    /// dates but real completions.
    var todaysProgress: Double {
        let totalToday = todaysTasks.count + overdueTasks.count + completedTodayTasks.count
        guard totalToday > 0 else { return 0 }
        return Double(completedTodayTasks.count) / Double(totalToday)
    }

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
            let allTasks = try taskRepository.fetchAll()
            let now = Date.now

            nextTask = prioritizationService.nextBestTask(among: allTasks, now: now)
            overdueTasks = prioritizationService.overdueTasks(in: allTasks, now: now)
            todaysTasks = prioritizationService.dueTodayTasks(in: allTasks, now: now)
            upcomingTasks = prioritizationService.upcomingTasks(in: allTasks, now: now, limit: 5)
            completedTodayTasks = prioritizationService.completedTodayTasks(in: allTasks, now: now)
            pinnedTasks = allTasks
                .filter { $0.isPinned && $0.status == .active }
                .sorted { $0.updatedAt > $1.updatedAt }

            errorMessage = nil
        } catch {
            errorMessage = "Couldn't load your tasks. Pull to refresh to try again."
        }
    }

    func complete(_ task: TaskItem) {
        do {
            try taskActionService.complete(task)
            refresh()
        } catch {
            errorMessage = "Couldn't complete \"\(task.title)\". Please try again."
        }
    }

    func togglePin(_ task: TaskItem) {
        do {
            try taskActionService.togglePin(task)
            refresh()
        } catch {
            errorMessage = "Couldn't update \"\(task.title)\". Please try again."
        }
    }

    func dismissError() {
        errorMessage = nil
    }
}
