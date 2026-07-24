import Testing
import Foundation
@testable import TaskPilotAI

@MainActor
struct RuleBasedTaskPrioritizationServiceTests {
    private let calendar = Calendar.autoupdatingCurrent
    private let now = Date(timeIntervalSince1970: 1_700_000_000) // fixed reference instant

    private func service() -> RuleBasedTaskPrioritizationService {
        RuleBasedTaskPrioritizationService(calendar: calendar)
    }

    @Test func nextBestTaskPrefersOverdueOverEverythingElse() {
        let overdue = TaskItem(
            title: "Overdue low priority",
            priority: .low,
            dueDate: calendar.date(byAdding: .day, value: -3, to: now),
            hasDueTime: false
        )
        let urgentUpcoming = TaskItem(
            title: "Urgent but future",
            priority: .urgent,
            dueDate: calendar.date(byAdding: .day, value: 5, to: now)
        )

        let result = service().nextBestTask(among: [urgentUpcoming, overdue], now: now)

        #expect(result?.title == "Overdue low priority")
    }

    @Test func nextBestTaskExcludesTasksWaitingOnOthers() {
        let waiting = TaskItem(
            title: "Blocked on Priya",
            priority: .urgent,
            dueDate: calendar.date(byAdding: .day, value: -1, to: now),
            isWaitingOnOthers: true
        )
        let actionable = TaskItem(title: "Doable now", priority: .low)

        let result = service().nextBestTask(among: [waiting, actionable], now: now)

        #expect(result?.title == "Doable now")
    }

    @Test func nextBestTaskIgnoresCompletedAndArchivedTasks() {
        let completed = TaskItem(title: "Done already", priority: .urgent, status: .completed, dueDate: now)
        let archived = TaskItem(title: "Shelved", priority: .urgent, status: .archived, dueDate: now)

        let result = service().nextBestTask(among: [completed, archived], now: now)

        #expect(result == nil)
    }

    @Test func overdueTasksAreSortedByOldestDueDateFirst() {
        let threeDaysLate = TaskItem(title: "3 days late", dueDate: calendar.date(byAdding: .day, value: -3, to: now))
        let oneDayLate = TaskItem(title: "1 day late", dueDate: calendar.date(byAdding: .day, value: -1, to: now))

        let result = service().overdueTasks(in: [oneDayLate, threeDaysLate], now: now)

        #expect(result.map(\.title) == ["3 days late", "1 day late"])
    }

    @Test func dueTodayExcludesOverdueTasks() {
        let dueToday = TaskItem(title: "Due today", dueDate: now, hasDueTime: true)
        let overdueYesterday = TaskItem(title: "Overdue", dueDate: calendar.date(byAdding: .day, value: -1, to: now))

        let result = service().dueTodayTasks(in: [dueToday, overdueYesterday], now: now)

        #expect(result.map(\.title) == ["Due today"])
    }

    @Test func upcomingTasksExcludeTodayAndRespectLimit() {
        let today = TaskItem(title: "Today", dueDate: now)
        let tomorrow = TaskItem(title: "Tomorrow", dueDate: calendar.date(byAdding: .day, value: 1, to: now))
        let nextWeek = TaskItem(title: "Next week", dueDate: calendar.date(byAdding: .day, value: 7, to: now))

        let result = service().upcomingTasks(in: [today, tomorrow, nextWeek], now: now, limit: 1)

        #expect(result.map(\.title) == ["Tomorrow"])
    }

    @Test func signalsClassifyQuickWinAndDeepWork() {
        let quickWin = TaskItem(title: "Quick", estimatedMinutes: 10)
        let deepWork = TaskItem(title: "Deep", estimatedMinutes: 90)

        let quickSignals = service().signals(for: quickWin, now: now)
        let deepSignals = service().signals(for: deepWork, now: now)

        #expect(quickSignals.isQuickWin)
        #expect(!quickSignals.isDeepWork)
        #expect(deepSignals.isDeepWork)
        #expect(!deepSignals.isQuickWin)
    }

    @Test func signalsMarkWaitingTasksAsWaiting() {
        let waiting = TaskItem(title: "Blocked", isWaitingOnOthers: true)

        let signals = service().signals(for: waiting, now: now)

        #expect(signals.isWaiting)
    }
}
