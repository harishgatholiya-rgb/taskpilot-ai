import Foundation

/// Decides what the single "next best task" is and how tasks classify into
/// the Dashboard's buckets.
///
/// The current implementation (`RuleBasedTaskPrioritizationService`) is
/// deterministic, rule-based logic. This protocol is the seam a future
/// AI-backed implementation (context-aware scheduling, learned priority
/// prediction) would conform to without changing any call site.
@MainActor
protocol TaskPrioritizationServiceProtocol {
    func nextBestTask(among tasks: [TaskItem], now: Date) -> TaskItem?
    func signals(for task: TaskItem, now: Date) -> TaskSignals
    func overdueTasks(in tasks: [TaskItem], now: Date) -> [TaskItem]
    func dueTodayTasks(in tasks: [TaskItem], now: Date) -> [TaskItem]
    func upcomingTasks(in tasks: [TaskItem], now: Date, limit: Int) -> [TaskItem]
    func completedTodayTasks(in tasks: [TaskItem], now: Date) -> [TaskItem]
}
