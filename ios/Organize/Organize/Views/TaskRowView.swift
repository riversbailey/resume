import SwiftUI
import SwiftData

struct TaskRowView: View {
    @Environment(\.modelContext) private var context
    @Bindable var task: TaskItem
    var showDueDate: Bool = false

    var body: some View {
        NavigationLink {
            TaskDetailView(task: task)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Button(action: toggleComplete) {
                    Image(systemName: task.isComplete ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(task.isComplete ? task.category?.color ?? .accentColor : .secondary)
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .strikethrough(task.isComplete, color: .secondary)
                        .foregroundStyle(task.isComplete ? .secondary : .primary)
                        .font(.body)

                    HStack(spacing: 8) {
                        if let category = task.category {
                            Label(category.name, systemImage: category.symbolName)
                                .font(.caption)
                                .foregroundStyle(category.color)
                        }

                        if task.priority == .high && !task.isComplete {
                            Label("High", systemImage: task.priority.symbolName)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }

                        if (showDueDate || task.isOverdue), let due = task.dueDate {
                            Label(due.formatted(.dateTime.month().day()), systemImage: "calendar")
                                .font(.caption)
                                .foregroundStyle(task.isOverdue ? .red : .secondary)
                        }
                    }
                }
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                toggleComplete()
            } label: {
                Label(
                    task.isComplete ? "Reopen" : "Done",
                    systemImage: task.isComplete ? "arrow.uturn.backward" : "checkmark"
                )
            }
            .tint(.green)
        }
    }

    private func toggleComplete() {
        withAnimation {
            task.isComplete.toggle()
            task.completedAt = task.isComplete ? Date() : nil
            try? context.save()
        }
    }
}
