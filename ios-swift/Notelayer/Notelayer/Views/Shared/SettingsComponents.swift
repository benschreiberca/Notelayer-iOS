import SwiftUI

// MARK: - Section Headers

/// ⚠️ DEPRECATED: Do NOT create custom section header components.
/// Use native iOS Section() headers instead:
///
/// ✅ Correct:   Section("Header Text") { ... }
/// ❌ Incorrect: SettingsSectionHeader(title: "Header Text")
///
/// This ensures:
/// - Automatic iOS-standard styling
/// - Consistency with native Settings app
/// - Scalability (future pages automatically consistent)
/// - Accessibility (VoiceOver support built-in)

// MARK: - Task Components (Extracted for Reuse)

/// Category chip matching the exact style from TaskItemView
struct TaskCategoryChip: View {
    @EnvironmentObject private var theme: ThemeManager
    let category: Category
    
    var body: some View {
        Text("\(category.icon) \(category.name)")
            .font(.caption)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background((Color(hex: category.color) ?? theme.tokens.accent).opacity(0.125))
            .foregroundStyle(theme.tokens.textSecondary.opacity(0.95))
            .clipShape(Capsule(style: .continuous))
    }
}

/// Priority badge matching the exact style from TaskItemView
struct TaskPriorityBadge: View {
    @EnvironmentObject private var theme: ThemeManager
    let priority: Priority
    
    var body: some View {
        Text(priorityText)
            .font(.caption)
            .foregroundStyle(theme.tokens.textSecondary)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
    }
    
    private var priorityText: String {
        switch priority {
        case .high: return "High"
        case .medium: return "Med"
        case .low: return "Low"
        case .deferred: return "Def"
        }
    }
}

// MARK: - Universal Button Style

/// Universal primary button style for all action buttons in the app
struct PrimaryButtonStyle: ButtonStyle {
    @EnvironmentObject var theme: ThemeManager
    var isDestructive: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isDestructive ? Color.red.opacity(0.1) : theme.tokens.accent)
            .foregroundColor(isDestructive ? .red : .white)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
