import AppIntents

/// Registers the Siri phrases that map to our App Intents. Discovered
/// automatically by the system at launch — no Info.plist entry needed.
/// Both English and Hindi phrasings are registered for each intent, so
/// either works regardless of the device's language setting.
struct TaskPilotShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddTaskIntent(),
            phrases: [
                "Add a task in \(.applicationName)",
                "Add a task to \(.applicationName)",
                "Create a task in \(.applicationName)",
                "\(.applicationName) में टास्क जोड़ो",
                "\(.applicationName) में एक टास्क जोड़ो"
            ],
            shortTitle: "Add Task",
            systemImageName: "plus.circle"
        )

        AppShortcut(
            intent: NextTaskIntent(),
            phrases: [
                "What's my next task in \(.applicationName)",
                "Show my next task in \(.applicationName)",
                "What should I do next in \(.applicationName)",
                "\(.applicationName) में मेरा अगला टास्क क्या है",
                "\(.applicationName) में अगला टास्क बताओ"
            ],
            shortTitle: "Next Task",
            systemImageName: "checkmark.circle"
        )
    }
}
