import SwiftUI

struct TaskFormView: View {
    @Bindable var viewModel: TaskFormViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var titleFieldFocused: Bool

    var body: some View {
        Form {
            Section {
                TextField("Task title", text: $viewModel.title)
                    .font(.body.weight(.medium))
                    .focused($titleFieldFocused)

                TextField("Notes", text: $viewModel.notes, axis: .vertical)
                    .lineLimit(3...6)
            }

            Section("Priority & Category") {
                Picker("Priority", selection: $viewModel.priority) {
                    ForEach(TaskPriority.allCases) { priority in
                        Label(priority.displayName, systemImage: priority.symbolName)
                            .tag(priority)
                    }
                }

                Picker("Category", selection: $viewModel.category) {
                    ForEach(TaskCategory.allCases) { category in
                        Label(category.displayName, systemImage: category.symbolName)
                            .tag(category)
                    }
                }
            }

            Section("Due Date") {
                Toggle("Has due date", isOn: $viewModel.hasDueDate.animation())

                if viewModel.hasDueDate {
                    DatePicker(
                        "Date",
                        selection: $viewModel.dueDate,
                        displayedComponents: [.date]
                    )

                    Toggle("Include time", isOn: $viewModel.hasDueTime.animation())

                    if viewModel.hasDueTime {
                        DatePicker(
                            "Time",
                            selection: $viewModel.dueDate,
                            displayedComponents: [.hourAndMinute]
                        )
                    }

                    Picker("Repeat", selection: $viewModel.repeatRule) {
                        ForEach(RepeatRule.allCases) { rule in
                            Text(rule.displayName).tag(rule)
                        }
                    }
                }
            }

            Section("Effort") {
                HStack {
                    Text("Estimated time")
                    Spacer()
                    TextField("minutes", text: $viewModel.estimatedMinutesText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                    Text("min")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Tags") {
                if !viewModel.tags.isEmpty {
                    tagChips
                }
                HStack {
                    TextField("Add a tag", text: $viewModel.tagDraft)
                        .onSubmit { viewModel.commitTagDraft() }
                    if !viewModel.tagDraft.trimmingCharacters(in: .whitespaces).isEmpty {
                        Button("Add") { viewModel.commitTagDraft() }
                    }
                }
            }

            Section {
                Toggle("Pinned", isOn: $viewModel.isPinned)
                Toggle("Waiting on someone else", isOn: $viewModel.isWaitingOnOthers)
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(viewModel.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    if viewModel.save() {
                        dismiss()
                    }
                }
                .disabled(viewModel.isSaveDisabled)
                .fontWeight(.semibold)
            }
        }
        .onAppear { titleFieldFocused = viewModel.title.isEmpty }
    }

    private var tagChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.sm) {
                ForEach(viewModel.tags, id: \.self) { tag in
                    HStack(spacing: Theme.Spacing.xs) {
                        Text(tag)
                            .font(.caption)
                        Button {
                            viewModel.removeTag(tag)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, Theme.Spacing.sm)
                    .padding(.vertical, Theme.Spacing.xs)
                    .background(Color.secondary.opacity(0.15), in: Capsule())
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TaskFormView(viewModel: TaskFormViewModel(taskRepository: InMemoryTaskRepository()))
    }
}
