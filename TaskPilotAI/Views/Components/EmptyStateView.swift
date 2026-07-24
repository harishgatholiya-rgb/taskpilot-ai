import SwiftUI

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    var message: String?

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 40))
                .foregroundStyle(.secondary)

            Text(title)
                .font(Theme.Typography.cardTitle)
                .foregroundStyle(.primary)

            if let message {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.xxl)
    }
}

#if DEBUG
#Preview {
    EmptyStateView(
        systemImage: "checkmark.circle",
        title: "All caught up",
        message: "Nothing due today. Enjoy the calm."
    )
}
#endif
