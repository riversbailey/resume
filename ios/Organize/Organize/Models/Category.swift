import Foundation
import SwiftData
import SwiftUI

@Model
final class Category {
    var name: String
    var symbolName: String
    var colorName: String
    var sortIndex: Int

    @Relationship(deleteRule: .nullify)
    var tasks: [TaskItem] = []

    init(name: String, symbolName: String, colorName: String, sortIndex: Int = 0) {
        self.name = name
        self.symbolName = symbolName
        self.colorName = colorName
        self.sortIndex = sortIndex
    }

    var color: Color {
        switch colorName {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "red": return .red
        case "purple": return .purple
        case "pink": return .pink
        case "yellow": return .yellow
        case "teal": return .teal
        case "gray": return .gray
        default: return .accentColor
        }
    }

    var openTaskCount: Int {
        tasks.filter { !$0.isComplete }.count
    }
}

extension Category {
    static let paletteColors: [String] = [
        "blue", "green", "orange", "red", "purple", "pink", "yellow", "teal", "gray"
    ]

    static let paletteSymbols: [String] = [
        "tray", "briefcase.fill", "house.fill", "cart.fill",
        "book.fill", "graduationcap.fill", "heart.fill", "star.fill",
        "airplane", "car.fill", "figure.run", "leaf.fill",
        "dumbbell.fill", "fork.knife", "gift.fill", "hammer.fill"
    ]
}
