import SwiftUI
import SwiftData

@main
struct OrganizeApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [Category.self, TaskItem.self]) { result in
            if case .success(let container) = result {
                seedIfNeeded(container: container)
            }
        }
    }

    private func seedIfNeeded(container: ModelContainer) {
        let context = container.mainContext
        let descriptor = FetchDescriptor<Category>()
        let existing = (try? context.fetch(descriptor)) ?? []
        guard existing.isEmpty else { return }

        let defaults: [(String, String, String)] = [
            ("Inbox", "tray", "gray"),
            ("Work", "briefcase.fill", "blue"),
            ("Personal", "house.fill", "green"),
            ("Errands", "cart.fill", "orange")
        ]
        for (index, entry) in defaults.enumerated() {
            let category = Category(
                name: entry.0,
                symbolName: entry.1,
                colorName: entry.2,
                sortIndex: index
            )
            context.insert(category)
        }
        try? context.save()
    }
}
