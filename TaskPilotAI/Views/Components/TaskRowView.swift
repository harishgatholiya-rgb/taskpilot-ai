import SwiftUI

/// Single-task row shared by the Dashboard's task lists and the full Task
/// Manager list. Completion is a tappable checkbox; the row itself carries
/// no navigation so callers can wrap it in whatever `NavigationLink` fits.
struct TaskRowView: View {
    let task: TaskItem
    var onToggleComplete: () -> Void

    private var isCompleted: Bool { task.status == .completed }

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.md) {
            Button(action: onToggleComplete) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isCompleted ? Color.accentColor : task.priority.tintColor.opacity(0.8))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isCompleted ? "Mark incomplete" : "Mark complete")

            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                HStack(spacing: Theme.Spacing.xs) {
                    Text(task.title)
                        .font(Theme.Typography.cardTitle)
                        .strikethrough(isCompleted)
                        .foregroundStyle(isCompleted ? .secondary : .primary)
                        .lineLimit(2)

                    if task.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                HStack(spacing: Theme.Spacing.sm) {
                    if let dueDateLabel = task.dueDateLabel {
                        Label(dueDateLabel, systemImage: "calendar")
                            .font(.caption)
                            .foregroundStyle(task.isOverdue ? .red : .secondary)
                    }

                    if let estimatedTimeLabel = task.estimatedTimeLabel {
                        Label(estimatedTimeLabel, systemImage: "clock")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if task.isWaitingOnOthers {
                        Label("Waiting", systemImage: "hourglass")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }

                CategoryChipView(category: task.category)
            }

            Spacer(minLength: 0)

            PriorityBadgeView(priority: task.priority)
        }
        .padding(.vertical, Theme.Spacing.xs)
        .contentShape(Rectangle())
    }
}

#if DEBUG
#Preview {
    List {
        TaskRowView(task: TaskItem.previewSeed[0]) {}
        TaskRowView(task: TaskItem.previewSeed[2]) {}
        TaskRowView(task: TaskItem.previewSeed[5]) {}
    }
}
#endif
