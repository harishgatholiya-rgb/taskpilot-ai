import SwiftUI

/// Shared layout constants so spacing and corner radii stay consistent
/// across the app instead of magic numbers scattered through views.
/// Colors intentionally lean on system semantic colors (not hardcoded hex)
/// so the app adapts correctly to light/dark mode and accessibility
/// contrast settings, per Apple HIG.
enum Theme {
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    enum CornerRadius {
        static let card: CGFloat = 16
        static let control: CGFloat = 12
        static let chip: CGFloat = 8
    }

    enum Typography {
        static let title = Font.system(.largeTitle, design: .rounded, weight: .bold)
        static let sectionHeader = Font.system(.title3, design: .rounded, weight: .semibold)
        static let cardTitle = Font.system(.headline, design: .default, weight: .semibold)
        static let body = Font.system(.body, design: .default)
        static let caption = Font.system(.caption, design: .default)
    }
}

extension Color {
    static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)
    static let screenBackground = Color(uiColor: .systemGroupedBackground)
}
