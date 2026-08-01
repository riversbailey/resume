import SwiftUI
import SwiftData

struct AddTaskView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Query(sort: [SortDescriptor(\Category.sortIndex), SortDescriptor(\Category.name)])
    private var categories: [Category]

    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var priority: Priority = .medium
    @State private var hasDueDate: Bool
    @State private var dueDate: Date
    @State private var selectedCategoryID: PersistentIdentifier?

    var defaultCategory: Category?
    var defaultDueDate: Date?

    init(defaultCategory: Category? = nil, defaultDueDate: Date? = nil) {
        self.defaultCategory = defaultCategory
        self.defaultDueDate = defaultDueDate
        _hasDueDate = State(initialValue: defaultDueDate != nil)
        _dueDate = State(initialValue: defaultDueDate ?? Calendar.current.startOfDay(for: Date()))
        _selectedCategoryID = State(initialValue: defaultCategory?.persistentModelID)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("What needs to happen?", text: $title, axis: .vertical)
                        .font(.title3.weight(.semibold))
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(2...6)
                }

                Section {
                    Picker(selection: $priority) {
                        ForEach(Priority.allCases) { level in
                            Label(level.label, systemImage: level.symbolName).tag(level)
                        }
                    } label: {
                        Label("Priority", systemImage: "flag")
                    }

                    Picker(selection: $selectedCategoryID) {
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
                    if hasDueDate {
                        DatePicker(
                            "When",
                            selection: $dueDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { save() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let category = categories.first { $0.persistentModelID == selectedCategoryID }
        let task = TaskItem(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: notes,
            isComplete: false,
            priority: priority,
            dueDate: hasDueDate ? dueDate : nil,
            category: category
        )
        context.insert(task)
        try? context.save()
        dismiss()
    }
}
