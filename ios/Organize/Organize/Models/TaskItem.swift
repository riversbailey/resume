import Foundation
import SwiftData

enum Priority: Int, Codable, CaseIterable, Identifiable {
    case low = 0
    case medium = 1
    case high = 2

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }

    var symbolName: String {
        switch self {
        case .low: return "flag"
        case .medium: return "flag.fill"
        case .high: return "exclamationmark.triangle.fill"
        }
    }
}

@Model
final class TaskItem {
    var title: String
    var notes: String
    var isComplete: Bool
    var priorityRaw: Int
    var dueDate: Date?
    var createdAt: Date
    var completedAt: Date?
    var sortIndex: Int

    @Relationship(inverse: \Category.tasks)
    var category: Category?

    init(
        title: String,
        notes: String = "",
        isComplete: Bool = false,
        priority: Priority = .medium,
        dueDate: Date? = nil,
        category: Category? = nil,
        sortIndex: Int = 0
    ) {
        self.title = title
        self.notes = notes
        self.isComplete = isComplete
        self.priorityRaw = priority.rawValue
        self.dueDate = dueDate
        self.createdAt = Date()
        self.completedAt = isComplete ? Date() : nil
        self.category = category
        self.sortIndex = sortIndex
    }

    var priority: Priority {
        get { Priority(rawValue: priorityRaw) ?? .medium }
        set { priorityRaw = newValue.rawValue }
    }

    var isOverdue: Bool {
        guard let due = dueDate, !isComplete else { return false }
        return due < Calendar.current.startOfDay(for: Date())
    }

    var isDueToday: Bool {
        guard let due = dueDate else { return false }
        return Calendar.current.isDateInToday(due)
    }
}
