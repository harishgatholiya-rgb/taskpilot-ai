import SwiftUI

struct TaskListView: View {
    private let container: AppDependencyContainer

    @State private var viewModel: TaskListViewModel
    @State private var showingAddForm = false

    init(container: AppDependencyContainer) {
        self.container = container
        _viewModel = State(initialValue: container.makeTaskListViewModel())
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Status", selection: $viewModel.statusFilter) {
                        ForEach(TaskListViewModel.StatusFilter.allCases) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }

                if viewModel.displayedTasks.isEmpty {
                    EmptyStateView(
                        systemImage: "checklist",
                        title: emptyStateTitle,
                        message: emptyStateMessage
                    )
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(viewModel.displayedTasks) { task in
                        NavigationLink(value: task) {
                            TaskRowView(task: task) {
                                viewModel.complete(task)
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                viewModel.delete(task)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            Button {
                                if task.status == .archived {
                                    viewModel.unarchive(task)
                                } else {
                                    viewModel.archive(task)
                                }
                            } label: {
                                Label(
                                    task.status == .archived ? "Restore" : "Archive",
                                    systemImage: "archivebox"
                                )
                            }
                            .tint(.orange)
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                viewModel.togglePin(task)
                            } label: {
                                Label(task.isPinned ? "Unpin" : "Pin", systemImage: "pin")
                            }
                            .tint(.indigo)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $viewModel.searchText, prompt: "Search tasks")
            .navigationTitle("Tasks")
            .navigationDestination(for: TaskItem.self) { task in
                TaskDetailView(container: container, task: task)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    sortAndFilterMenu
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddForm = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Task")
                }
            }
            .sheet(isPresented: $showingAddForm, onDismiss: { viewModel.refresh() }) {
                NavigationStack {
                    TaskFormView(viewModel: container.makeTaskFormViewModel())
                }
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

    private var sortAndFilterMenu: some View {
        Menu {
            Picker("Sort by", selection: $viewModel.sortOption) {
                ForEach(TaskListViewModel.SortOption.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }

            Menu("Category") {
                Button("All Categories") { viewModel.selectedCategory = nil }
                ForEach(TaskCategory.allCases) { category in
                    Button(category.displayName) { viewModel.selectedCategory = category }
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
        }
        .accessibilityLabel("Sort and filter")
    }

    private var emptyStateTitle: String {
        switch viewModel.statusFilter {
        case .active: "No active tasks"
        case .completed: "Nothing completed yet"
        case .archived: "Nothing archived"
        }
    }

    private var emptyStateMessage: String? {
        switch viewModel.statusFilter {
        case .active: "Tap + to add your first task."
        case .completed, .archived: nil
        }
    }
}

#if DEBUG
#Preview {
    TaskListView(container: .preview())
}
#endif
