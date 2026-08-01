# Organize — native iOS app

A simple SwiftUI + SwiftData organizer with tasks, lists, priorities, and due
dates. Runs on iPhone and iPad, iOS 17+.

## Structure

```
ios/Organize/
├── Organize.xcodeproj/       Xcode project
└── Organize/
    ├── OrganizeApp.swift     App entry point + seed data
    ├── Models/
    │   ├── TaskItem.swift    SwiftData model for a task
    │   └── Category.swift    SwiftData model for a list
    └── Views/
        ├── RootView.swift            Tab shell
        ├── TodayView.swift           Overdue / today / next 7 days
        ├── AllTasksView.swift        Search, filter, all tasks
        ├── CategoriesView.swift      Lists + per-list detail
        ├── TaskRowView.swift         Reusable task row
        ├── TaskDetailView.swift      Edit a task
        ├── AddTaskView.swift         Create a task
        └── EditCategoryView.swift    Create/edit a list
```

## Build and run on your device

1. Open `ios/Organize/Organize.xcodeproj` in Xcode 15 or later on a Mac.
2. In the target's **Signing & Capabilities** tab, pick your Apple ID team
   and change the bundle identifier if `com.paulriversbailey.Organize` is
   already taken on your account.
3. Plug in your iPhone, select it as the run destination, and press ⌘R.
4. The first launch on a physical device may require trusting your
   developer certificate under **Settings › General › VPN & Device
   Management**.

## Features

- **Today** tab: overdue, due today, next 7 days, and undated open tasks.
- **Lists** tab: create colored lists with SF Symbol icons, drill into each.
- **All** tab: filter Open/Done/All, full-text search.
- Priorities (low/medium/high), due dates with time, notes.
- Swipe-to-complete and swipe-to-delete on any row.
- Local persistence via SwiftData — no account, no network.

## Extending

To add sync across devices later, wrap the model container with iCloud:

```swift
.modelContainer(
    for: [Category.self, TaskItem.self],
    configurations: ModelConfiguration(cloudKitDatabase: .private("iCloud.com.paulriversbailey.Organize"))
)
```

Then enable the iCloud capability with CloudKit in the target settings.
