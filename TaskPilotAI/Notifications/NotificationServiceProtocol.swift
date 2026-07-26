import Foundation

/// Local reminder notifications for tasks with a due date. Distinct from
/// `TaskActionServiceProtocol` (which mutates task data) — this only talks
/// to `UNUserNotificationCenter`, never touches persistence.
@MainActor
protocol NotificationServiceProtocol {
    func requestAuthorizationIfNeeded()

    /// Schedules (or replaces) the reminder for this task based on its due
    /// date. No-ops if the task has no due date, is not active, or the
    /// computed reminder time has already passed.
    func scheduleReminder(for task: TaskItem)

    /// Cancels any pending reminder for this task. Safe to call even if
    /// none is scheduled.
    func cancelReminder(for task: TaskItem)

    /// Replaces this task's reminder with one firing `minutes` from now,
    /// regardless of the task's own due date. Backs the notification's
    /// "Snooze" action.
    func scheduleSnoozeReminder(for task: TaskItem, minutes: Int)
}

/// Identifiers shared between `LocalNotificationService` (which schedules
/// notifications) and the app delegate (which handles the user tapping
/// their actions), so both sides agree on the contract without importing
/// each other.
enum TaskReminderNotification {
    static let categoryIdentifier = "TASK_REMINDER"
    static let completeActionIdentifier = "COMPLETE_ACTION"
    static let snoozeActionIdentifier = "SNOOZE_ACTION"
    static let taskIDUserInfoKey = "taskID"
}
