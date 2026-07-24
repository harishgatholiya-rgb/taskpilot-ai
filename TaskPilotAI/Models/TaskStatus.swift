import Foundation

/// Lifecycle state of a task. Distinct from `PrioritySignal`, which only
/// applies to tasks that are `.active`.
enum TaskStatus: String, Codable, Hashable {
    case active
    case completed
    case archived
}
