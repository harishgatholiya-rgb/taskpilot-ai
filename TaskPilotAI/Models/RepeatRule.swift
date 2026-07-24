import Foundation

/// How a task recurs. `none` means it does not repeat.
enum RepeatRule: String, Codable, CaseIterable, Identifiable, Hashable {
    case none
    case daily
    case weekdays
    case weekly
    case biweekly
    case monthly
    case yearly

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none: "Never"
        case .daily: "Daily"
        case .weekdays: "Weekdays"
        case .weekly: "Weekly"
        case .biweekly: "Every 2 weeks"
        case .monthly: "Monthly"
        case .yearly: "Yearly"
        }
    }

    /// Computes the next occurrence strictly after `date`, or `nil` if this
    /// rule does not repeat. `calendar` defaults to autoupdatingCurrent so
    /// callers get the user's current locale/timezone unless testing.
    func nextOccurrence(after date: Date, calendar: Calendar = .autoupdatingCurrent) -> Date? {
        switch self {
        case .none:
            return nil
        case .daily:
            return calendar.date(byAdding: .day, value: 1, to: date)
        case .weekdays:
            var next = date
            repeat {
                guard let candidate = calendar.date(byAdding: .day, value: 1, to: next) else {
                    return nil
                }
                next = candidate
            } while calendar.isDateInWeekend(next)
            return next
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: date)
        case .biweekly:
            return calendar.date(byAdding: .weekOfYear, value: 2, to: date)
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: date)
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: date)
        }
    }
}
