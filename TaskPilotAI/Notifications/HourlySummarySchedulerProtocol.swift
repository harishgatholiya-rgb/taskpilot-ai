import Foundation

/// Keeps the hourly summary notification's content in sync with the
/// current task state. Call `refresh()` whenever it's a good time to
/// re-read the task list — the Dashboard does this every time it appears.
@MainActor
protocol HourlySummarySchedulerProtocol {
    func refresh()
}
