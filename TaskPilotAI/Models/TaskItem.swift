import Foundation
import SwiftData

/// A single task. This is the app's core persisted entity.
///
/// Date handling: `dueDate` always stores a full `Date` when present.
/// `hasDueTime` distinguishes "due sometime on this day" (time component is
/// ignored by the UI and set to start-of-day) from "due at this exact time".
@Model
final class TaskItem {
    @Attribute(.unique) var id: UUID

    var title: String
    var notes: String
    var tags: [String]

    var priorityRaw: TaskPriority.RawValue
    var categoryRaw: TaskCategory.RawValue
    var statusRaw: TaskStatus.RawValue
    var repeatRuleRaw: RepeatRule.RawValue

    var dueDate: Date?
    var hasDueTime: Bool

    /// Rough effort estimate in minutes, used for "quick win" vs "deep work"
    /// classification. Nil means unestimated.
    var estimatedMinutes: Int?

    /// Blocked on someone/something else — surfaces under the "Waiting"
    /// bucket instead of being offered as the next best task.
    var isWaitingOnOthers: Bool

    var isPinned: Bool

    var createdAt: Date
    var updatedAt: Date
    var completedAt: Date?

    /// When a repeating task is completed, the freshly-created next
    /// occurrence points back at the task it was spawned from.
    var repeatedFromID: UUID?

    init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        tags: [String] = [],
        priority: TaskPriority = .medium,
        category: TaskCategory = .other,
        status: TaskStatus = .active,
        repeatRule: RepeatRule = .none,
        dueDate: Date? = nil,
        hasDueTime: Bool = false,
        estimatedMinutes: Int? = nil,
        isWaitingOnOthers: Bool = false,
        isPinned: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        completedAt: Date? = nil,
        repeatedFromID: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.tags = tags
        self.priorityRaw = priority.rawValue
        self.categoryRaw = category.rawValue
        self.statusRaw = status.rawValue
        self.repeatRuleRaw = repeatRule.rawValue
        self.dueDate = dueDate
        self.hasDueTime = hasDueTime
        self.estimatedMinutes = estimatedMinutes
        self.isWaitingOnOthers = isWaitingOnOthers
        self.isPinned = isPinned
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.completedAt = completedAt
        self.repeatedFromID = repeatedFromID
    }
}

// MARK: - Typed accessors

extension TaskItem {
    var priority: TaskPriority {
        get { TaskPriority(rawValue: priorityRaw) ?? .medium }
        set { priorityRaw = newValue.rawValue }
    }

    var category: TaskCategory {
        get { TaskCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    var status: TaskStatus {
        get { TaskStatus(rawValue: statusRaw) ?? .active }
        set { statusRaw = newValue.rawValue }
    }

    var repeatRule: RepeatRule {
        get { RepeatRule(rawValue: repeatRuleRaw) ?? .none }
        set { repeatRuleRaw = newValue.rawValue }
    }
}

// MARK: - Derived state

extension TaskItem {
    var isOverdue: Bool {
        guard status == .active, let dueDate else { return false }
        if hasDueTime {
            return dueDate < .now
        }
        return Calendar.autoupdatingCurrent.startOfDay(for: dueDate) < Calendar.autoupdatingCurrent.startOfDay(for: .now)
    }

    var isDueToday: Bool {
        guard let dueDate else { return false }
        return Calendar.autoupdatingCurrent.isDateInToday(dueDate)
    }

    var isCompleted: Bool { status == .completed }
}
