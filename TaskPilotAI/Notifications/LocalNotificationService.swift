import Foundation
import UserNotifications

/// Schedules due-date reminders via `UNUserNotificationCenter`.
///
/// Timing rule: tasks with an explicit due *time* get a reminder
/// `leadTimeMinutes` before that time; tasks with only a due *date* get a
/// reminder at `allDayReminderHour` on that day. One request per task,
/// keyed by the task's UUID, so re-scheduling naturally replaces any
/// existing reminder.
@MainActor
final class LocalNotificationService: NotificationServiceProtocol {
    private let center = UNUserNotificationCenter.current()
    private let calendar: Calendar

    private static let leadTimeMinutes = 15
    private static let allDayReminderHour = 9

    init(calendar: Calendar = .autoupdatingCurrent) {
        self.calendar = calendar
        registerNotificationCategory()
    }

    func requestAuthorizationIfNeeded() {
        center.getNotificationSettings { [center] settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        }
    }

    func scheduleReminder(for task: TaskItem) {
        cancelReminder(for: task)

        guard task.status == .active, let fireDate = reminderDate(for: task), fireDate > .now else {
            return
        }

        schedule(taskID: task.id, title: task.title, body: reminderBody(for: task), fireDate: fireDate)
    }

    func cancelReminder(for task: TaskItem) {
        center.removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
    }

    func scheduleSnoozeReminder(for task: TaskItem, minutes: Int) {
        guard let fireDate = calendar.date(byAdding: .minute, value: minutes, to: .now) else { return }
        schedule(taskID: task.id, title: task.title, body: "Snoozed reminder", fireDate: fireDate)
    }

    // MARK: - Private

    private func schedule(taskID: UUID, title: String, body: String, fireDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = TaskReminderNotification.categoryIdentifier
        content.userInfo = [TaskReminderNotification.taskIDUserInfoKey: taskID.uuidString]

        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: taskID.uuidString, content: content, trigger: trigger)

        center.add(request)
    }

    private func reminderBody(for task: TaskItem) -> String {
        guard task.hasDueTime, let dueDate = task.dueDate else {
            return "Due today"
        }
        return "Due at \(dueDate.shortTimeLabel)"
    }

    private func reminderDate(for task: TaskItem) -> Date? {
        guard let dueDate = task.dueDate else { return nil }
        if task.hasDueTime {
            return calendar.date(byAdding: .minute, value: -Self.leadTimeMinutes, to: dueDate)
        }
        return calendar.date(bySettingHour: Self.allDayReminderHour, minute: 0, second: 0, of: dueDate)
    }

    private func registerNotificationCategory() {
        let completeAction = UNNotificationAction(
            identifier: TaskReminderNotification.completeActionIdentifier,
            title: "Mark Complete",
            options: []
        )
        let snoozeAction = UNNotificationAction(
            identifier: TaskReminderNotification.snoozeActionIdentifier,
            title: "Snooze 15 min",
            options: []
        )
        let category = UNNotificationCategory(
            identifier: TaskReminderNotification.categoryIdentifier,
            actions: [completeAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )
        center.setNotificationCategories([category])
    }
}
