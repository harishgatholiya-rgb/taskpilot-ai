import UIKit
import UserNotifications

/// Handles taps on notification actions ("Mark Complete" / "Snooze 15 min").
/// Kept separate from the SwiftUI `App` struct since `UNUserNotificationCenterDelegate`
/// needs a reference type registered before the first notification can arrive.
final class AppDelegate: NSObject, UIApplicationDelegate {
    @MainActor var container: AppDependencyContainer?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .list]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        guard
            let taskIDString = response.notification.request.content.userInfo[TaskReminderNotification.taskIDUserInfoKey] as? String,
            let taskID = UUID(uuidString: taskIDString)
        else {
            return
        }

        await MainActor.run {
            guard let container else { return }
            do {
                guard let task = try container.taskRepository.fetch(id: taskID) else { return }
                switch response.actionIdentifier {
                case TaskReminderNotification.completeActionIdentifier:
                    try container.taskActionService.complete(task)
                case TaskReminderNotification.snoozeActionIdentifier:
                    container.notificationService.scheduleSnoozeReminder(for: task, minutes: 15)
                default:
                    break
                }
            } catch {
                // Best-effort: nothing actionable to surface from a notification response handler.
            }
        }
    }
}
