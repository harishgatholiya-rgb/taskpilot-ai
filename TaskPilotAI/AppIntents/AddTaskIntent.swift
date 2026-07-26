import AppIntents
import Foundation

/// "Add a task in My Task" — Siri collects the title (and optionally a due
/// date) and this creates the task without opening the app. Also
/// recognized in Hindi (see `TaskPilotShortcutsProvider`); the spoken
/// confirmation matches whichever language the device prefers.
struct AddTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Task"
    static var description = IntentDescription("Adds a new task to My Task.")
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Title")
    var taskTitle: String

    @Parameter(title: "Due Date")
    var dueDate: Date?

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$taskTitle) to My Task") {
            \.$dueDate
        }
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let container = try TaskPilotIntentContainer.shared()

        let task = TaskItem(title: taskTitle, dueDate: dueDate, hasDueTime: dueDate != nil)
        try container.taskRepository.create(task)
        container.notificationService.scheduleReminder(for: task)

        return .result(dialog: IntentDialog(stringLiteral: confirmationText(for: task)))
    }

    private func confirmationText(for task: TaskItem) -> String {
        if PreferredLanguage.isHindi {
            if let dueDateLabel = task.dueDateLabel {
                return "\"\(taskTitle)\" माई टास्क में जोड़ दिया गया, \(dueDateLabel) तक।"
            }
            return "\"\(taskTitle)\" माई टास्क में जोड़ दिया गया।"
        }

        if let dueDateLabel = task.dueDateLabel {
            return "Added \"\(taskTitle)\" to My Task, due \(dueDateLabel)."
        }
        return "Added \"\(taskTitle)\" to My Task."
    }
}
