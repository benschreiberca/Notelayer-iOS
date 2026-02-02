import SwiftUI

/// Multi-line grid of tappable category chips for selection
/// Shows ALL categories without truncation, wrapping to multiple lines as needed
/// Used in share extension for compact, visual category selection
struct CategoryChipGridView: View {
    let categories: [Category]
    @Binding var selectedIds: Set<String>
    var size: CategoryChipSize = .standard
    
    // Visual styling
    private let chipSpacing: CGFloat = 8
    private let lineSpacing: CGFloat = 8
    
    var body: some View {
        FlowLayout(spacing: chipSpacing, lineSpacing: lineSpacing) {
            ForEach(categories) { category in
                CategoryChipButton(
                    category: category,
                    isSelected: selectedIds.contains(category.id),
                    size: size,
                    onTap: {
                        toggleSelection(category.id)
                    }
                )
            }
        }
    }
    
    private func toggleSelection(_ id: String) {
        if selectedIds.contains(id) {
            selectedIds.remove(id)
        } else {
            selectedIds.insert(id)
        }
    }
}

/// Individual category chip button with icon and name
/// Visual states: selected (filled) vs unselected (outlined)
private struct CategoryChipButton: View {
    let category: Category
    let isSelected: Bool
    let size: CategoryChipSize
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Text(category.icon)
                    .font(size.font)
                Text(category.name)
                    .font(size.font)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(borderColor, lineWidth: isSelected ? 0 : 1.2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
    
    private var backgroundColor: Color {
        isSelected ? categoryColor.opacity(0.22) : .clear
    }
    
    private var foregroundColor: Color {
        isSelected ? categoryColor : categoryColor
    }
    
    private var borderColor: Color {
        isSelected ? .clear : categoryColor
    }
    
    private var categoryColor: Color {
        Color(hex: category.color) ?? .blue
    }
}

/// Size presets for category chips.
enum CategoryChipSize {
    case standard
    case large

    var horizontalPadding: CGFloat {
        switch self {
        case .standard:
            return 12
        case .large:
            return 15
        }
    }

    var verticalPadding: CGFloat {
        switch self {
        case .standard:
            return 6
        case .large:
            return 7.5
        }
    }

    var font: Font {
        .caption
    }
}

/// FlowLayout: Custom layout that arranges views in a multi-line grid
/// Views wrap to next line when they exceed available width
/// Based on standard SwiftUI geometry calculations
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let layout = computeLayout(proposal: proposal, subviews: subviews)
        
        for (index, subview) in subviews.enumerated() {
            if let position = layout.positions[index] {
                let point = CGPoint(
                    x: bounds.minX + position.x,
                    y: bounds.minY + position.y
                )
                subview.place(at: point, proposal: ProposedViewSize(layout.sizes[index]))
            }
        }
    }
    
    private struct LayoutResult {
        var size: CGSize = .zero
        var positions: [Int: CGPoint] = [:]
        var sizes: [CGSize] = []
    }
    
    private func computeLayout(proposal: ProposedViewSize, subviews: Subviews) -> LayoutResult {
        var result = LayoutResult()
        let availableWidth = proposal.width ?? .infinity
        
        // Measure all subviews
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        result.sizes = sizes
        
        // Arrange views line by line
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxWidth: CGFloat = 0
        
        for (index, size) in sizes.enumerated() {
            // Check if view fits on current line
            if currentX + size.width > availableWidth && currentX > 0 {
                // Move to next line
                currentY += lineHeight + lineSpacing
                currentX = 0
                lineHeight = 0
            }
            
            // Place view
            result.positions[index] = CGPoint(x: currentX, y: currentY)
            
            // Update tracking variables
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
            maxWidth = max(maxWidth, currentX - spacing)
        }
        
        // Final size
        result.size = CGSize(
            width: min(maxWidth, availableWidth),
            height: currentY + lineHeight
        )
        
        return result
    }
}
