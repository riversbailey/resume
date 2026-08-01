import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var context
    @Query private var allTasks: [TaskItem]
    @State private var showingAdd = false

    private var overdue: [TaskItem] {
        allTasks
            .filter { !$0.isComplete && $0.isOverdue }
            .sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
    }

    private var today: [TaskItem] {
        allTasks
            .filter { !$0.isComplete && $0.isDueToday }
            .sorted { $0.priority.rawValue > $1.priority.rawValue }
    }

    private var upcoming: [TaskItem] {
        let end = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        return allTasks.filter { task in
            guard !task.isComplete, let due = task.dueDate else { return false }
            return !task.isDueToday && !task.isOverdue && due <= end
        }
        .sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
    }

    private var noDate: [TaskItem] {
        allTasks
            .filter { !$0.isComplete && $0.dueDate == nil }
            .sorted { $0.priority.rawValue > $1.priority.rawValue }
    }

    var body: some View {
        List {
            if !overdue.isEmpty {
                Section {
                    ForEach(overdue) { task in
                        TaskRowView(task: task)
                    }
                    .onDelete { indices in delete(from: overdue, at: indices) }
                } header: {
                    Label("Overdue", systemImage: "exclamationmark.circle.fill")
                        .foregroundStyle(.red)
                }
            }

            Section {
                if today.isEmpty {
                    Text("Nothing due today. Nice.")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                        .padding(.vertical, 4)
                } else {
                    ForEach(today) { task in
                        TaskRowView(task: task)
                    }
                    .onDelete { indices in delete(from: today, at: indices) }
                }
            } header: {
                Label("Today", systemImage: "sun.max.fill")
            }

            if !upcoming.isEmpty {
                Section {
                    ForEach(upcoming) { task in
                        TaskRowView(task: task, showDueDate: true)
                    }
                    .onDelete { indices in delete(from: upcoming, at: indices) }
                } header: {
                    Label("Next 7 days", systemImage: "calendar")
                }
            }

            if !noDate.isEmpty {
                Section {
                    ForEach(noDate) { task in
                        TaskRowView(task: task)
                    }
                    .onDelete { indices in delete(from: noDate, at: indices) }
                } header: {
                    Label("No due date", systemImage: "tray")
                }
            }
        }
        .navigationTitle("Today")
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
            AddTaskView(defaultDueDate: Date())
        }
    }

    private func delete(from source: [TaskItem], at offsets: IndexSet) {
        for index in offsets {
            let task = source[index]
            context.delete(task)
        }
        try? context.save()
    }
}

#Preview {
    NavigationStack { TodayView() }
        .modelContainer(for: [Category.self, TaskItem.self], inMemory: true)
}
