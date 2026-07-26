import Foundation

#if DEBUG
/// No-op `NotificationServiceProtocol` for SwiftUI previews and unit tests,
/// so neither has to touch the real `UNUserNotificationCenter` (which
/// prompts for permission and requires a real device/simulator context).
@MainActor
final class NoOpNotificationService: NotificationServiceProtocol {
    func requestAuthorizationIfNeeded() {}
    func scheduleReminder(for task: TaskItem) {}
    func cancelReminder(for task: TaskItem) {}
    func scheduleSnoozeReminder(for task: TaskItem, minutes: Int) {}
    func rescheduleHourlySummary(title: String, body: String) {}
    func cancelHourlySummary() {}
}
#endif
