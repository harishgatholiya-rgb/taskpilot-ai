import SwiftUI

struct DashboardView: View {
    private let container: AppDependencyContainer

    @State private var viewModel: DashboardViewModel
    @State private var showingQuickAdd = false

    init(container: AppDependencyContainer) {
        self.container = container
        _viewModel = State(initialValue: container.makeDashboardViewModel())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                    header

                    NextTaskCardView(
                        task: viewModel.nextTask,
                        onComplete: { viewModel.complete($0) }
                    )

                    if !viewModel.overdueTasks.isEmpty {
                        taskSection(title: "Overdue", systemImage: "exclamationmark.triangle.fill", tasks: viewModel.overdueTasks)
                    }

                    if !viewModel.pinnedTasks.isEmpty {
                        taskSection(title: "Pinned", systemImage: "pin.fill", tasks: viewModel.pinnedTasks)
                    }

                    if !viewModel.todaysTasks.isEmpty {
                        taskSection(title: "Today", systemImage: "sun.max.fill", tasks: viewModel.todaysTasks)
                    }

                    if !viewModel.upcomingTasks.isEmpty {
                        taskSection(title: "Upcoming", systemImage: "calendar", tasks: viewModel.upcomingTasks)
                    }

                    if !viewModel.completedTodayTasks.isEmpty {
                        taskSection(title: "Completed Today", systemImage: "checkmark.circle.fill", tasks: viewModel.completedTodayTasks)
                    }

                    if viewModel.nextTask == nil && viewModel.overdueTasks.isEmpty && viewModel.todaysTasks.isEmpty {
                        EmptyStateView(
                            systemImage: "sparkles",
                            title: "Nothing on your plate",
                            message: "Tap the + button to add your first task."
                        )
                    }
                }
                .padding(Theme.Spacing.lg)
            }
            .background(Color.screenBackground)
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingQuickAdd = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .accessibilityLabel("Quick Add Task")
                }
            }
            .sheet(isPresented: $showingQuickAdd, onDismiss: { viewModel.refresh() }) {
                NavigationStack {
                    TaskFormView(viewModel: container.makeTaskFormViewModel())
                }
            }
            .navigationDestination(for: TaskItem.self) { task in
                TaskDetailView(container: container, task: task)
                    .onDisappear { viewModel.refresh() }
            }
            .onAppear { viewModel.refresh() }
            .refreshable { viewModel.refresh() }
            .alert(
                "Something went wrong",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { isPresented in if !isPresented { viewModel.dismissError() } }
                ),
                presenting: viewModel.errorMessage
            ) { _ in
                Button("OK") { viewModel.dismissError() }
            } message: { message in
                Text(message)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(greeting)
                    .font(Theme.Typography.title)
                Text(Date.now.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            ProgressRingView(progress: viewModel.todaysProgress, lineWidth: 8, diameter: 64)
        }
    }

    private var greeting: String {
        switch Calendar.autoupdatingCurrent.component(.hour, from: .now) {
        case 0..<12: "Good morning"
        case 12..<17: "Good afternoon"
        default: "Good evening"
        }
    }

    @ViewBuilder
    private func taskSection(title: String, systemImage: String, tasks: [TaskItem]) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Label(title, systemImage: systemImage)
                .font(Theme.Typography.sectionHeader)

            VStack(spacing: 0) {
                ForEach(tasks) { task in
                    NavigationLink(value: task) {
                        TaskRowView(task: task) {
                            viewModel.complete(task)
                        }
                    }
                    .buttonStyle(.plain)

                    if task.id != tasks.last?.id {
                        Divider()
                    }
                }
            }
            .padding(Theme.Spacing.md)
            .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.card))
        }
    }
}

#Preview {
    DashboardView(container: .preview())
}
