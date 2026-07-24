import SwiftUI

struct PriorityBadgeView: View {
    let priority: TaskPriority

    var body: some View {
        Label(priority.displayName, systemImage: priority.symbolName)
            .labelStyle(.iconOnly)
            .font(.caption.weight(.semibold))
            .foregroundStyle(priority.tintColor)
            .accessibilityLabel("\(priority.displayName) priority")
    }
}

#Preview {
    HStack(spacing: Theme.Spacing.md) {
        ForEach(TaskPriority.allCases) { priority in
            PriorityBadgeView(priority: priority)
        }
    }
    .padding()
}
