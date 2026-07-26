import SwiftUI

@main
struct TaskPilotAIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    private let container: AppDependencyContainer

    init() {
        do {
            let modelContainer = try AppDependencyContainer.makeProductionModelContainer()
            container = AppDependencyContainer(modelContainer: modelContainer)
        } catch {
            fatalError("Failed to initialize the SwiftData store: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootTabView(container: container)
                .task {
                    appDelegate.container = container
                }
        }
    }
}
