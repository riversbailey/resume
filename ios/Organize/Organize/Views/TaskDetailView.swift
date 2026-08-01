import SwiftUI
import SwiftData

struct TaskDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Bindable var task: TaskItem

    @Query(sort: [SortDescriptor(\Category.sortIndex), SortDescriptor(\Category.name)])
    private var categories: [Category]

    @State private var hasDueDate: Bool

    init(task: TaskItem) {
        self.task = task
        _hasDueDate = State(initialValue: task.dueDate != nil)
    }

    var body: some View {
        Form {
            Section {
                TextField("Title", text: $task.title, axis: .vertical)
                    .font(.title3.weight(.semibold))

                TextField("Notes", text: $task.notes, axis: .vertical)
                    .lineLimit(3...10)
            }

            Section {
                Toggle(isOn: Binding(
                    get: { task.isComplete },
                    set: { newValue in
                        task.isComplete = newValue
                        task.completedAt = newValue ? Date() : nil
                    }
                )) {
                    Label("Completed", systemImage: "checkmark.circle.fill")
                }

                Picker(selection: Binding(
                    get: { task.priority },
                    set: { task.priority = $0 }
                )) {
                    ForEach(Priority.allCases) { level in
                        Label(level.label, systemImage: level.symbolName).tag(level)
                    }
                } label: {
                    Label("Priority", systemImage: "flag")
                }

                Picker(selection: Binding(
                    get: { task.category?.persistentModelID },
                    set: { newID in
                        task.category = categories.first { $0.persistentModelID == newID }
                    }
                )) {
                    Text("None").tag(PersistentIdentifier?.none)
                    ForEach(categories) { category in
                        Label(category.name, systemImage: category.symbolName)
                            .tag(Optional(category.persistentModelID))
                    }
                } label: {
                    Label("List", systemImage: "list.bullet")
                }
            }

            Section {
                Toggle(isOn: $hasDueDate) {
                    Label("Due date", systemImage: "calendar")
                }
                .onChange(of: hasDueDate) { _, newValue in
                    if newValue && task.dueDate == nil {
                        task.dueDate = Calendar.current.startOfDay(for: Date())
                    } else if !newValue {
                        task.dueDate = nil
                    }
                }

                if hasDueDate {
                    DatePicker(
                        "When",
                        selection: Binding(
                            get: { task.dueDate ?? Date() },
                            set: { task.dueDate = $0 }
                        ),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
            }

            Section {
                Button(role: .destructive) {
                    context.delete(task)
                    try? context.save()
                    dismiss()
                } label: {
                    Label("Delete task", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Task")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            try? context.save()
        }
    }
}
