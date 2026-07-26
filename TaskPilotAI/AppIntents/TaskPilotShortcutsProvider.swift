import AppIntents

/// Registers the Siri phrases that map to our App Intents. Discovered
/// automatically by the system at launch — no Info.plist entry needed.
struct TaskPilotShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddTaskIntent(),
            phrases: [
                "Add a task in \(.applicationName)",
                "Add a task to \(.applicationName)",
                "Create a task in \(.applicationName)"
            ],
            shortTitle: "Add Task",
            systemImageName: "plus.circle"
        )

        AppShortcut(
            intent: NextTaskIntent(),
            phrases: [
                "What's my next task in \(.applicationName)",
                "Show my next task in \(.applicationName)",
                "What should I do next in \(.applicationName)"
            ],
            shortTitle: "Next Task",
            systemImageName: "checkmark.circle"
        )
    }
}
