import Foundation

@MainActor
final class HourlySummaryScheduler: HourlySummarySchedulerProtocol {
    private let taskRepository: TaskRepositoryProtocol
    private let prioritizationService: TaskPrioritizationServiceProtocol
    private let notificationService: NotificationServiceProtocol

    init(
        taskRepository: TaskRepositoryProtocol,
        prioritizationService: TaskPrioritizationServiceProtocol,
        notificationService: NotificationServiceProtocol
    ) {
        self.taskRepository = taskRepository
        self.prioritizationService = prioritizationService
        self.notificationService = notificationService
    }

    func refresh() {
        guard let tasks = try? taskRepository.fetchAll() else { return }

        let now = Date.now
        let overdueCount = prioritizationService.overdueTasks(in: tasks, now: now).count
        let dueTodayCount = prioritizationService.dueTodayTasks(in: tasks, now: now).count
        let next = prioritizationService.nextBestTask(among: tasks, now: now)

        let (title, body) = Self.summaryText(overdueCount: overdueCount, dueTodayCount: dueTodayCount, next: next)
        notificationService.rescheduleHourlySummary(title: title, body: body)
    }

    private static func summaryText(overdueCount: Int, dueTodayCount: Int, next: TaskItem?) -> (title: String, body: String) {
        if PreferredLanguage.isHindi {
            var parts: [String] = []
            if overdueCount > 0 { parts.append("\(overdueCount) टास्क बकाया हैं") }
            if dueTodayCount > 0 { parts.append("\(dueTodayCount) आज के लिए हैं") }
            if let next { parts.append("अगला टास्क: \(next.title)") }

            let body = parts.isEmpty
                ? "अभी किसी टास्क पर ध्यान देने की ज़रूरत नहीं है।"
                : parts.joined(separator: "। ") + "।"
            return ("आपके टास्क", body)
        }

        var parts: [String] = []
        if overdueCount > 0 { parts.append("\(overdueCount) overdue") }
        if dueTodayCount > 0 { parts.append("\(dueTodayCount) due today") }
        if let next { parts.append("next: \(next.title)") }

        let body = parts.isEmpty
            ? "Nothing needs your attention right now."
            : parts.joined(separator: ", ").capitalizingFirstLetter() + "."
        return ("Your Tasks", body)
    }
}

private extension String {
    func capitalizingFirstLetter() -> String {
        guard let first else { return self }
        return first.uppercased() + dropFirst()
    }
}
