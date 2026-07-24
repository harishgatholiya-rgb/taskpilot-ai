import SwiftUI

struct TaskDetailView: View {
    private let container: AppDependencyContainer

    @State private var viewModel: TaskDetailViewModel
    @State private var showingEditForm = false
    @State private var showingDeleteConfirmation = false
    @Environment(\.dismiss) private var dismiss

    init(container: AppDependencyContainer, task: TaskItem) {
        self.container = container
        _viewModel = State(initialValue: container.makeTaskDetailViewModel(task: task))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                titleSection
                metadataSection
                if !viewModel.task.notes.isEmpty {
                    notesSection
                }
                if !viewModel.task.tags.isEmpty {
                    tagsSection
                }
                statusSection
            }
            .padding(Theme.Spacing.lg)
        }
        .background(Color.screenBackground)
        .navigationTitle("Task")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showingEditForm = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }

                    Button {
                        viewModel.togglePin()
                    } label: {
                        Label(viewModel.task.isPinned ? "Unpin" : "Pin", systemImage: "pin")
                    }

                    Button {
                        viewModel.toggleArchive()
                    } label: {
                        Label(
                            viewModel.task.status == .archived ? "Unarchive" : "Archive",
                            systemImage: "archivebox"
                        )
                    }

                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditForm) {
            NavigationStack {
                TaskFormView(viewModel: container.makeTaskFormViewModel(editing: viewModel.task))
            }
        }
        .confirmationDialog(
            "Delete this task?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                viewModel.delete()
            }
        } message: {
            Text("This can't be undone.")
        }
        .onChange(of: viewModel.wasDeleted) { _, wasDeleted in
            if wasDeleted { dismiss() }
        }
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

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(viewModel.task.title)
                .font(Theme.Typography.title)
                .strikethrough(viewModel.task.isCompleted)

            Button {
                viewModel.toggleComplete()
            } label: {
                Label(
                    viewModel.task.isCompleted ? "Completed" : "Mark Complete",
                    systemImage: viewModel.task.isCompleted ? "checkmark.circle.fill" : "circle"
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.sm)
            }
            .buttonStyle(.borderedProminent)
            .tint(viewModel.task.isCompleted ? .secondary : .accentColor)
        }
    }

    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                PriorityBadgeView(priority: viewModel.task.priority)
                Text(viewModel.task.priority.displayName)
                    .font(.subheadline)
                Spacer()
                CategoryChipView(category: viewModel.task.category)
            }

            if let dueDateLabel = viewModel.task.dueDateLabel {
                Label(dueDateLabel, systemImage: "calendar")
                    .foregroundStyle(viewModel.task.isOverdue ? .red : .primary)
            }

            if viewModel.task.repeatRule != .none {
                Label("Repeats \(viewModel.task.repeatRule.displayName.lowercased())", systemImage: "repeat")
            }

            if let estimatedTimeLabel = viewModel.task.estimatedTimeLabel {
                Label(estimatedTimeLabel, systemImage: "clock")
            }

            if viewModel.task.isWaitingOnOthers {
                Label("Waiting on someone else", systemImage: "hourglass")
                    .foregroundStyle(.orange)
            }
        }
        .font(.subheadline)
        .padding(Theme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.card))
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Notes")
                .font(Theme.Typography.sectionHeader)
            Text(viewModel.task.notes)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Tags")
                .font(Theme.Typography.sectionHeader)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.sm) {
                    ForEach(viewModel.task.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, Theme.Spacing.sm)
                            .padding(.vertical, Theme.Spacing.xs)
                            .background(Color.secondary.opacity(0.15), in: Capsule())
                    }
                }
            }
        }
    }

    private var statusSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("Created \(viewModel.task.createdAt.formatted(date: .abbreviated, time: .omitted))")
            if let completedAt = viewModel.task.completedAt {
                Text("Completed \(completedAt.formatted(date: .abbreviated, time: .shortened))")
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
}

#Preview {
    NavigationStack {
        TaskDetailView(container: .preview(), task: TaskItem.previewSeed[0])
    }
}
