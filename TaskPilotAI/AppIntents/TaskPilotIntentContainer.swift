import Foundation

/// App Intents (Siri/Shortcuts) run outside the SwiftUI view hierarchy, so
/// they can't reach `AppDependencyContainer` through the environment like
/// views do. This lazily builds one shared instance pointing at the same
/// on-disk SwiftData store the main app uses, so a task added via Siri
/// shows up in the app and vice versa.
@MainActor
enum TaskPilotIntentContainer {
    private static var cached: AppDependencyContainer?

    static func shared() throws -> AppDependencyContainer {
        if let cached {
            return cached
        }
        let modelContainer = try AppDependencyContainer.makeProductionModelContainer()
        let container = AppDependencyContainer(modelContainer: modelContainer)
        cached = container
        return container
    }
}
