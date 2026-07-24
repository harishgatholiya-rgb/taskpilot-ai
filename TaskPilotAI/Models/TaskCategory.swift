import SwiftUI

/// Built-in task categories. A fixed set keeps the model simple for the MVP;
/// promoting this to a user-managed entity is a natural extension later.
enum TaskCategory: String, Codable, CaseIterable, Identifiable, Hashable {
    case work
    case personal
    case health
    case finance
    case shopping
    case learning
    case home
    case errands
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .work: "Work"
        case .personal: "Personal"
        case .health: "Health"
        case .finance: "Finance"
        case .shopping: "Shopping"
        case .learning: "Learning"
        case .home: "Home"
        case .errands: "Errands"
        case .other: "Other"
        }
    }

    var symbolName: String {
        switch self {
        case .work: "briefcase.fill"
        case .personal: "person.fill"
        case .health: "heart.fill"
        case .finance: "dollarsign.circle.fill"
        case .shopping: "cart.fill"
        case .learning: "book.fill"
        case .home: "house.fill"
        case .errands: "checklist"
        case .other: "square.grid.2x2.fill"
        }
    }

    var tintColor: Color {
        switch self {
        case .work: .indigo
        case .personal: .purple
        case .health: .pink
        case .finance: .green
        case .shopping: .teal
        case .learning: .cyan
        case .home: .brown
        case .errands: .mint
        case .other: .gray
        }
    }
}
