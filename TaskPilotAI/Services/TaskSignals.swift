import Foundation

/// Computed classification for a single task, derived fresh from its data
/// and the current time — never persisted. Powers the Dashboard's
/// Overdue / Quick Wins / Deep Work / Waiting groupings.
struct TaskSignals: Equatable {
    var isOverdue: Bool
    var isDueToday: Bool
    var isUrgent: Bool
    var isImportant: Bool
    var isQuickWin: Bool
    var isDeepWork: Bool
    var isWaiting: Bool
}
