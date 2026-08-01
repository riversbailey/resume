import SwiftUI
import SwiftData

struct AllTasksView: View {
    enum Filter: String, CaseIterable, Identifiable {
        case open = "Open"
        case done = "Done"
        case all = "All"
        var id: String { rawValue }
    }

    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\TaskItem.createdAt, order: .reverse)])
    private var allTasks: [TaskItem]

    @State private var filter: Filter = .open
    @State private var query: String = ""
    @State private var showingAdd = false

    private var filteredTasks: [TaskItem] {
        allTasks
            .filter { task in
                switch filter {
                case .open: return !task.isComplete
                case .done: return task.isComplete
                case .all: return true
                }
            }
            .filter { task in
                guard !query.isEmpty else { return true }
                return task.title.localizedCaseInsensitiveContains(query)
                    || task.notes.localizedCaseInsensitiveContains(query)
            }
    }

    var body: some View {
        List {
            Picker("Filter", selection: $filter) {
                ForEach(Filter.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

            if filteredTasks.isEmpty {
                ContentUnavailableView(
                    "No tasks",
                    systemImage: "checkmark.seal",
                    description: Text("Tap the + button to add one.")
                )
                .listRowBackground(Color.clear)
            } else {
                ForEach(filteredTasks) { task in
                    TaskRowView(task: task, showDueDate: true)
                }
                .onDelete(perform: delete)
            }
        }
        .searchable(text: $query, prompt: "Search tasks")
        .navigationTitle("All Tasks")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAdd = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            AddTaskView()
        }
    }

    private func delete(at offsets: IndexSet) {
        let source = filteredTasks
        for index in offsets {
            context.delete(source[index])
        }
        try? context.save()
    }
}

#Preview {
    NavigationStack { AllTasksView() }
        .modelContainer(for: [Category.self, TaskItem.self], inMemory: true)
}
