import AppIntents

/// "Add a task in My Task" — Siri collects the title (and optionally a
/// due date) and this creates the task without opening the app.
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

        if let dueDateLabel = task.dueDateLabel {
            return .result(dialog: "Added \"\(taskTitle)\" to My Task, due \(dueDateLabel).")
        }
        return .result(dialog: "Added \"\(taskTitle)\" to My Task.")
    }
}
