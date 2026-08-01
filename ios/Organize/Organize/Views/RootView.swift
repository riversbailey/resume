import SwiftUI
import SwiftData

struct RootView: View {
    var body: some View {
        TabView {
            NavigationStack {
                TodayView()
            }
            .tabItem { Label("Today", systemImage: "sun.max.fill") }

            NavigationStack {
                CategoriesView()
            }
            .tabItem { Label("Lists", systemImage: "list.bullet.rectangle.fill") }

            NavigationStack {
                AllTasksView()
            }
            .tabItem { Label("All", systemImage: "tray.full.fill") }
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: [Category.self, TaskItem.self], inMemory: true)
}
