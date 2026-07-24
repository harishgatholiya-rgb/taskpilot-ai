import SwiftUI

/// User-assigned urgency/importance level for a task.
///
/// Distinct from `PrioritySignal` (Services/TaskPrioritizationService.swift),
/// which is the *computed* Eisenhower-style classification the app derives
/// from this value plus due date proximity.
enum TaskPriority: Int, Codable, CaseIterable, Identifiable, Comparable, Hashable {
    case low = 0
    case medium = 1
    case high = 2
    case urgent = 3

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        case .urgent: "Urgent"
        }
    }

    var symbolName: String {
        switch self {
        case .low: "arrow.down.circle.fill"
        case .medium: "equal.circle.fill"
        case .high: "arrow.up.circle.fill"
        case .urgent: "exclamationmark.circle.fill"
        }
    }

    var tintColor: Color {
        switch self {
        case .low: .blue
        case .medium: .yellow
        case .high: .orange
        case .urgent: .red
        }
    }

    static func < (lhs: TaskPriority, rhs: TaskPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
