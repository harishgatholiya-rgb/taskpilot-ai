import Foundation
import SwiftData

#if DEBUG
extension AppDependencyContainer {
    /// In-memory container with representative seed data, for SwiftUI
    /// previews and manual testing builds. Never used in the shipping app.
    static func preview(seed: [TaskItem] = TaskItem.previewSeed) -> AppDependencyContainer {
        let schema = Schema([TaskItem.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        guard let container = try? ModelContainer(for: schema, configurations: [configuration]) else {
            fatalError("Failed to create in-memory preview ModelContainer for TaskItem schema.")
        }

        for task in seed {
            container.mainContext.insert(task)
        }

        return AppDependencyContainer(modelContainer: container)
    }
}

extension TaskItem {
    static var previewSeed: [TaskItem] {
        let calendar = Calendar.autoupdatingCurrent
        let now = Date.now

        return [
            TaskItem(
                title: "Send Q3 investor update",
                notes: "Include revenue chart and hiring plan.",
                tags: ["investors", "writing"],
                priority: .urgent,
                category: .work,
                dueDate: calendar.date(byAdding: .hour, value: -2, to: now),
                hasDueTime: true,
                estimatedMinutes: 45,
                isPinned: true
            ),
            TaskItem(
                title: "Call Mukesh about contract",
                priority: .high,
                category: .work,
                dueDate: calendar.date(bySettingHour: 15, minute: 0, second: 0, of: now),
                hasDueTime: true,
                estimatedMinutes: 10
            ),
            TaskItem(
                title: "Buy groceries",
                priority: .low,
                category: .shopping,
                dueDate: calendar.startOfDay(for: now),
                hasDueTime: false,
                estimatedMinutes: 20
            ),
            TaskItem(
                title: "Renew passport",
                priority: .medium,
                category: .personal,
                dueDate: calendar.date(byAdding: .day, value: 5, to: now),
                estimatedMinutes: 90
            ),
            TaskItem(
                title: "Waiting on design review from Priya",
                priority: .medium,
                category: .work,
                isWaitingOnOthers: true
            ),
            TaskItem(
                title: "Morning workout",
                priority: .medium,
                category: .health,
                status: .completed,
                estimatedMinutes: 30,
                completedAt: now
            )
        ]
    }
}
#endif
