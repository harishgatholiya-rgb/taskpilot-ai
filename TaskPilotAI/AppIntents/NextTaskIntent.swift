import AppIntents
import Foundation

/// "What's my next task in TaskBuddy" — Siri speaks back whatever the
/// prioritization service currently considers the next best task, using
/// the same rule-based logic the Dashboard's hero card shows. Also
/// recognized in Hindi (see `TaskPilotShortcutsProvider`).
struct NextTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Show Next Task"
    static var description = IntentDescription("Tells you the next best task to work on in TaskBuddy.")
    static var openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let container = try TaskPilotIntentContainer.shared()
        let tasks = try container.taskRepository.fetchAll()
        let next = container.prioritizationService.nextBestTask(among: tasks, now: .now)

        return .result(dialog: IntentDialog(stringLiteral: responseText(for: next)))
    }

    private func responseText(for task: TaskItem?) -> String {
        guard let task else {
            return PreferredLanguage.isHindi
                ? "आप पूरी तरह से तैयार हैं। अभी किसी टास्क पर ध्यान देने की ज़रूरत नहीं है।"
                : "You're all caught up. No tasks need your attention right now."
        }

        if PreferredLanguage.isHindi {
            if let dueDateLabel = task.dueDateLabel {
                return "आपका अगला टास्क है \(task.title), \(dueDateLabel) तक।"
            }
            return "आपका अगला टास्क है \(task.title)।"
        }

        if let dueDateLabel = task.dueDateLabel {
            return "Your next task is \(task.title), due \(dueDateLabel)."
        }
        return "Your next task is \(task.title)."
    }
}
