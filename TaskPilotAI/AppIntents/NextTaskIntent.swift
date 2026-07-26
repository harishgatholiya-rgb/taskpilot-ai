import AppIntents

/// "What's my next task in My Task" — Siri speaks back whatever the
/// prioritization service currently considers the next best task, using
/// the same rule-based logic the Dashboard's hero card shows.
struct NextTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Show Next Task"
    static var description = IntentDescription("Tells you the next best task to work on in My Task.")
    static var openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let container = try TaskPilotIntentContainer.shared()
        let tasks = try container.taskRepository.fetchAll()

        guard let next = container.prioritizationService.nextBestTask(among: tasks, now: .now) else {
            return .result(dialog: "You're all caught up. No tasks need your attention right now.")
        }

        if let dueDateLabel = next.dueDateLabel {
            return .result(dialog: "Your next task is \(next.title), due \(dueDateLabel).")
        }
        return .result(dialog: "Your next task is \(next.title).")
    }
}
