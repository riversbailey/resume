import SwiftUI
import SwiftData

struct CategoriesView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\Category.sortIndex), SortDescriptor(\Category.name)])
    private var categories: [Category]

    @State private var showingNewCategory = false

    var body: some View {
        List {
            ForEach(categories) { category in
                NavigationLink {
                    CategoryDetailView(category: category)
                } label: {
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(category.color.opacity(0.15))
                                .frame(width: 36, height: 36)
                            Image(systemName: category.symbolName)
                                .foregroundStyle(category.color)
                        }
                        VStack(alignment: .leading) {
                            Text(category.name)
                                .font(.body)
                            Text("^[\(category.openTaskCount) task](inflect: true) open")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Lists")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingNewCategory = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
        }
        .sheet(isPresented: $showingNewCategory) {
            EditCategoryView()
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            context.delete(categories[index])
        }
        try? context.save()
    }
}

struct CategoryDetailView: View {
    @Environment(\.modelContext) private var context
    @Bindable var category: Category

    @State private var showingAdd = false
    @State private var showingEdit = false

    private var openTasks: [TaskItem] {
        category.tasks
            .filter { !$0.isComplete }
            .sorted { lhs, rhs in
                if lhs.priority.rawValue != rhs.priority.rawValue {
                    return lhs.priority.rawValue > rhs.priority.rawValue
                }
                return (lhs.dueDate ?? .distantFuture) < (rhs.dueDate ?? .distantFuture)
            }
    }

    private var completedTasks: [TaskItem] {
        category.tasks
            .filter { $0.isComplete }
            .sorted { ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast) }
    }

    var body: some View {
        List {
            Section("Open") {
                if openTasks.isEmpty {
                    Text("Nothing here. Add a task.")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                } else {
                    ForEach(openTasks) { task in
                        TaskRowView(task: task, showDueDate: true)
                    }
                    .onDelete { indices in delete(openTasks, at: indices) }
                }
            }

            if !completedTasks.isEmpty {
                Section("Completed") {
                    ForEach(completedTasks) { task in
                        TaskRowView(task: task, showDueDate: true)
                    }
                    .onDelete { indices in delete(completedTasks, at: indices) }
                }
            }
        }
        .navigationTitle(category.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAdd = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingEdit = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            AddTaskView(defaultCategory: category)
        }
        .sheet(isPresented: $showingEdit) {
            EditCategoryView(category: category)
        }
    }

    private func delete(_ source: [TaskItem], at offsets: IndexSet) {
        for index in offsets {
            context.delete(source[index])
        }
        try? context.save()
    }
}

#Preview {
    NavigationStack { CategoriesView() }
        .modelContainer(for: [Category.self, TaskItem.self], inMemory: true)
}
