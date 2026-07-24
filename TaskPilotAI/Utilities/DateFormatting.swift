import Foundation

extension Date {
    /// "Today", "Tomorrow", "Yesterday", or a short date like "Fri, Aug 1".
    func relativeDayLabel(calendar: Calendar = .autoupdatingCurrent) -> String {
        if calendar.isDateInToday(self) { return "Today" }
        if calendar.isDateInTomorrow(self) { return "Tomorrow" }
        if calendar.isDateInYesterday(self) { return "Yesterday" }

        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEE, MMM d")
        return formatter.string(from: self)
    }

    /// Locale-aware short time, e.g. "9:41 AM".
    var shortTimeLabel: String {
        self.formatted(date: .omitted, time: .shortened)
    }
}

extension TaskItem {
    /// Human-readable due date for list rows and detail views, e.g.
    /// "Today at 3:00 PM", "Tomorrow", "Fri, Aug 1".
    var dueDateLabel: String? {
        guard let dueDate else { return nil }
        let dayLabel = dueDate.relativeDayLabel()
        guard hasDueTime else { return dayLabel }
        return "\(dayLabel) at \(dueDate.shortTimeLabel)"
    }

    /// Compact effort label, e.g. "15 min" or "1 hr 30 min".
    var estimatedTimeLabel: String? {
        guard let estimatedMinutes, estimatedMinutes > 0 else { return nil }
        if estimatedMinutes < 60 {
            return "\(estimatedMinutes) min"
        }
        let hours = estimatedMinutes / 60
        let minutes = estimatedMinutes % 60
        return minutes == 0 ? "\(hours) hr" : "\(hours) hr \(minutes) min"
    }
}
