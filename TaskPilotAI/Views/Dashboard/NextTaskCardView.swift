import SwiftUI

/// The Dashboard's hero card: the single next best thing to do right now.
///
/// Must be used inside a `NavigationStack` with `.navigationDestination(for:
/// TaskItem.self)` registered, since the title area navigates via
/// `NavigationLink(value:)`. The "Mark Complete" button is a sibling of that
/// link (not nested inside it) — nesting a `Button` inside another
/// `Button`/`NavigationLink`'s label is unreliable for taps in SwiftUI.
struct NextTaskCardView: View {
    let task: TaskItem?
    var onComplete: (TaskItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Next up")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            if let task {
                content(for: task)
            } else {
                emptyContent
            }
        }
        .padding(Theme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.card))
    }

    private func content(for task: TaskItem) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            NavigationLink(value: task) {
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Text(task.title)
                        .font(Theme.Typography.title.weight(.bold))
                        .foregroundStyle(.primary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: Theme.Spacing.sm) {
                        if let dueDateLabel = task.dueDateLabel {
                            Label(dueDateLabel, systemImage: "calendar")
                                .foregroundStyle(task.isOverdue ? .red : .secondary)
                        }
                        if let estimatedTimeLabel = task.estimatedTimeLabel {
                            Label(estimatedTimeLabel, systemImage: "clock")
                                .foregroundStyle(.secondary)
                        }
                        CategoryChipView(category: task.category)
                    }
                    .font(.caption)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button {
                onComplete(task)
            } label: {
                Label("Mark Complete", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.sm)
            }
            .buttonStyle(.borderedProminent)
            .tint(.accentColor)
            .padding(.top, Theme.Spacing.xs)
        }
    }

    private var emptyContent: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("You're all caught up")
                .font(Theme.Typography.cardTitle)
            Text("No active tasks need your attention right now.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        VStack(spacing: Theme.Spacing.lg) {
            NextTaskCardView(task: TaskItem.previewSeed[0], onComplete: { _ in })
            NextTaskCardView(task: nil, onComplete: { _ in })
        }
        .padding()
        .background(Color.screenBackground)
        .navigationDestination(for: TaskItem.self) { task in
            TaskDetailView(container: .preview(), task: task)
        }
    }
}
#endif
