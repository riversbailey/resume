import SwiftUI
import SwiftData

struct EditCategoryView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var category: Category?

    @State private var name: String
    @State private var symbolName: String
    @State private var colorName: String

    init(category: Category? = nil) {
        self.category = category
        _name = State(initialValue: category?.name ?? "")
        _symbolName = State(initialValue: category?.symbolName ?? "tray")
        _colorName = State(initialValue: category?.colorName ?? "blue")
    }

    private var previewColor: Color {
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

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(previewColor.opacity(0.2))
                                    .frame(width: 72, height: 72)
                                Image(systemName: symbolName)
                                    .font(.title)
                                    .foregroundStyle(previewColor)
                            }
                            Text(name.isEmpty ? "New list" : name)
                                .font(.headline)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }

                Section("Name") {
                    TextField("Name", text: $name)
                }

                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(Category.paletteColors, id: \.self) { option in
                            colorSwatch(option)
                        }
                    }
                    .padding(.vertical, 6)
                }

                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(Category.paletteSymbols, id: \.self) { name in
                            symbolButton(name)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle(category == nil ? "New List" : "Edit List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func colorSwatch(_ option: String) -> some View {
        let color = colorFor(option)
        return Button {
            colorName = option
        } label: {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 32, height: 32)
                if colorName == option {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func symbolButton(_ name: String) -> some View {
        Button {
            symbolName = name
        } label: {
            Image(systemName: name)
                .font(.title3)
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(symbolName == name ? previewColor.opacity(0.25) : Color.secondary.opacity(0.1))
                )
                .foregroundStyle(symbolName == name ? previewColor : .primary)
        }
        .buttonStyle(.plain)
    }

    private func colorFor(_ option: String) -> Color {
        switch option {
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

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if let category {
            category.name = trimmed
            category.symbolName = symbolName
            category.colorName = colorName
        } else {
            let descriptor = FetchDescriptor<Category>()
            let count = (try? context.fetchCount(descriptor)) ?? 0
            let created = Category(
                name: trimmed,
                symbolName: symbolName,
                colorName: colorName,
                sortIndex: count
            )
            context.insert(created)
        }
        try? context.save()
        dismiss()
    }
}
