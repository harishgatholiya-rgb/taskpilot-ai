import SwiftUI

struct CategoryChipView: View {
    let category: TaskCategory

    var body: some View {
        Label(category.displayName, systemImage: category.symbolName)
            .font(.caption.weight(.medium))
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, Theme.Spacing.xs)
            .background(category.tintColor.opacity(0.15), in: Capsule())
            .foregroundStyle(category.tintColor)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
        ForEach(TaskCategory.allCases) { category in
            CategoryChipView(category: category)
        }
    }
    .padding()
}
