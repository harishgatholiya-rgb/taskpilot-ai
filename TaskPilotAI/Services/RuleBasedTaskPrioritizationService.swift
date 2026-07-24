import Foundation

/// Deterministic scoring model for "what's the next best thing to do".
///
/// Scoring, highest wins:
///   - overdue tasks: +1000, so nothing outranks a slipping deadline
///   - due today: +500
///   - has a future due date: up to +200, decaying with distance
///   - priority: +0/100/200/300 (low/medium/high/urgent)
///   - pinned: +50
///   - quick win (<=15 estimated minutes): +10, to fight decision fatigue
/// Tasks the user marked as waiting on someone else are never surfaced as
/// the next best task, since the user can't act on them right now.
/// Ties break by earliest due date, then oldest created-at (FIFO).
@MainActor
final class RuleBasedTaskPrioritizationService: TaskPrioritizationServiceProtocol {
    private let calendar: Calendar

    private static let quickWinThresholdMinutes = 15
    private static let deepWorkThresholdMinutes = 60

    init(calendar: Calendar = .autoupdatingCurrent) {
        self.calendar = calendar
    }

    func nextBestTask(among tasks: [TaskItem], now: Date = .now) -> TaskItem? {
        candidates(from: tasks)
            .filter { !$0.isWaitingOnOthers }
            .max { lhs, rhs in
                let lhsScore = score(for: lhs, now: now)
                let rhsScore = score(for: rhs, now: now)
                if lhsScore != rhsScore { return lhsScore < rhsScore }
                return tieBreak(lhs, rhs)
            }
    }

    func signals(for task: TaskItem, now: Date = .now) -> TaskSignals {
        let overdue = task.status == .active && isOverdue(task, now: now)
        let dueToday = task.dueDate.map { calendar.isDate($0, inSameDayAs: now) } ?? false
        let minutes = task.estimatedMinutes

        return TaskSignals(
            isOverdue: overdue,
            isDueToday: dueToday,
            isUrgent: overdue || dueToday || task.priority == .urgent,
            isImportant: task.priority == .high || task.priority == .urgent,
            isQuickWin: (minutes ?? .max) <= Self.quickWinThresholdMinutes,
            isDeepWork: (minutes ?? 0) >= Self.deepWorkThresholdMinutes,
            isWaiting: task.isWaitingOnOthers
        )
    }

    func overdueTasks(in tasks: [TaskItem], now: Date = .now) -> [TaskItem] {
        candidates(from: tasks)
            .filter { isOverdue($0, now: now) }
            .sorted { ($0.dueDate ?? .distantPast) < ($1.dueDate ?? .distantPast) }
    }

    func dueTodayTasks(in tasks: [TaskItem], now: Date = .now) -> [TaskItem] {
        candidates(from: tasks)
            .filter { task in
                guard let dueDate = task.dueDate else { return false }
                return calendar.isDate(dueDate, inSameDayAs: now) && !isOverdue(task, now: now)
            }
            .sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
    }

    func upcomingTasks(in tasks: [TaskItem], now: Date = .now, limit: Int = 10) -> [TaskItem] {
        let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) ?? now

        return candidates(from: tasks)
            .filter { task in
                guard let dueDate = task.dueDate else { return false }
                return dueDate >= startOfTomorrow
            }
            .sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
            .prefix(limit)
            .map { $0 }
    }

    func completedTodayTasks(in tasks: [TaskItem], now: Date = .now) -> [TaskItem] {
        tasks
            .filter { task in
                guard task.status == .completed, let completedAt = task.completedAt else { return false }
                return calendar.isDate(completedAt, inSameDayAs: now)
            }
            .sorted { ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast) }
    }

    // MARK: - Private

    private func candidates(from tasks: [TaskItem]) -> [TaskItem] {
        tasks.filter { $0.status == .active }
    }

    private func isOverdue(_ task: TaskItem, now: Date) -> Bool {
        guard let dueDate = task.dueDate else { return false }
        if task.hasDueTime {
            return dueDate < now
        }
        return calendar.startOfDay(for: dueDate) < calendar.startOfDay(for: now)
    }

    private func score(for task: TaskItem, now: Date) -> Int {
        var score = 0

        if isOverdue(task, now: now) {
            score += 1000
        } else if let dueDate = task.dueDate {
            if calendar.isDate(dueDate, inSameDayAs: now) {
                score += 500
            } else if let daysUntilDue = calendar.dateComponents([.day], from: now, to: dueDate).day, daysUntilDue >= 0 {
                score += max(0, 200 - daysUntilDue * 5)
            }
        }

        score += task.priority.rawValue * 100

        if task.isPinned {
            score += 50
        }

        if let minutes = task.estimatedMinutes, minutes <= Self.quickWinThresholdMinutes {
            score += 10
        }

        return score
    }

    private func tieBreak(_ lhs: TaskItem, _ rhs: TaskItem) -> Bool {
        let lhsDue = lhs.dueDate ?? .distantFuture
        let rhsDue = rhs.dueDate ?? .distantFuture
        if lhsDue != rhsDue { return lhsDue > rhsDue }
        return lhs.createdAt > rhs.createdAt
    }
}
