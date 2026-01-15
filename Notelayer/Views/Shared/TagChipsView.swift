import SwiftUI
import UIKit

struct TagChip: Identifiable, Hashable {
    let id: String
    let text: String
    let color: Color
}

/// Calmer, compact tag chips:
/// - Tries to keep in 1 line; wraps to 2 lines max.
/// - If more, truncates with "+N".
struct TagChipsView: View {
    let chips: [TagChip]

    // Visual tuning (calmer tints)
    private let chipFont: UIFont = .preferredFont(forTextStyle: .caption1)
    private let hPad: CGFloat = 10
    private let vPad: CGFloat = 5
    private let spacing: CGFloat = 6
    private let lineSpacing: CGFloat = 6

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let layout = computeLayout(availableWidth: width)
            VStack(alignment: .leading, spacing: lineSpacing) {
                HStack(spacing: spacing) {
                    ForEach(layout.line1) { chip in
                        chipView(chip)
                    }
                }
                if !layout.line2.isEmpty || layout.hiddenCount > 0 {
                    HStack(spacing: spacing) {
                        ForEach(layout.line2) { chip in
                            chipView(chip)
                        }
                        if layout.hiddenCount > 0 {
                            chipView(TagChip(id: "more", text: "+\(layout.hiddenCount)", color: Color.secondary))
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: estimatedHeight)
    }

    private var estimatedHeight: CGFloat {
        // Two-line max, fixed height to avoid layout jumps.
        // Chip height: font line height + reveal padding.
        let h = chipFont.lineHeight + vPad * 2
        return h * 2 + lineSpacing
    }

    private func chipView(_ chip: TagChip) -> some View {
        Text(chip.text)
            .font(.caption)
            .lineLimit(1)
            .padding(.horizontal, hPad)
            .padding(.vertical, vPad)
            .background(chip.color.opacity(0.12))
            .foregroundStyle(chip.color.opacity(0.85))
            .clipShape(Capsule(style: .continuous))
    }

    private struct LayoutResult {
        var line1: [TagChip] = []
        var line2: [TagChip] = []
        var hiddenCount: Int = 0
    }

    private func computeLayout(availableWidth: CGFloat) -> LayoutResult {
        guard availableWidth > 0 else { return LayoutResult() }

        // Compute chip widths
        let measured: [(TagChip, CGFloat)] = chips.map { chip in
            (chip, measureChipWidth(chip.text))
        }

        var line1: [TagChip] = []
        var line2: [TagChip] = []
        var w1: CGFloat = 0
        var w2: CGFloat = 0

        for (chip, w) in measured {
            if line2.isEmpty {
                if fits(current: w1, next: w, available: availableWidth) {
                    w1 = advance(current: w1, next: w)
                    line1.append(chip)
                    continue
                }
                // start line2
                w2 = w
                line2.append(chip)
                continue
            } else {
                if fits(current: w2, next: w, available: availableWidth) {
                    w2 = advance(current: w2, next: w)
                    line2.append(chip)
                    continue
                }
                break
            }
        }

        let shown = line1.count + line2.count
        var hidden = max(0, chips.count - shown)

        // Reserve space for "+N" on line2 if hidden.
        if hidden > 0 {
            var plusText = "+\(hidden)"
            var plusW = measureChipWidth(plusText, color: .secondary)

            // Ensure "+N" can fit; if not, remove chips from end of line2 then line1.
            while true {
                let currentLine2Width = totalWidth(of: line2, current: w2)
                let wouldFit = fits(current: currentLine2Width, next: plusW, available: availableWidth)
                if wouldFit || (line1.isEmpty && line2.isEmpty) { break }

                if !line2.isEmpty {
                    line2.removeLast()
                } else if !line1.isEmpty {
                    line1.removeLast()
                } else {
                    break
                }
                let newShown = line1.count + line2.count
                hidden = max(0, chips.count - newShown)
                plusText = "+\(hidden)"
                plusW = measureChipWidth(plusText, color: .secondary)
                w1 = totalWidth(of: line1, current: 0)
                w2 = totalWidth(of: line2, current: 0)
            }
        }

        return LayoutResult(line1: line1, line2: line2, hiddenCount: hidden)
    }

    private func totalWidth(of line: [TagChip], current: CGFloat) -> CGFloat {
        var w: CGFloat = 0
        for (idx, chip) in line.enumerated() {
            let mw = measureChipWidth(chip.text)
            w += mw
            if idx != line.count - 1 { w += spacing }
        }
        return w
    }

    private func fits(current: CGFloat, next: CGFloat, available: CGFloat) -> Bool {
        if current == 0 { return next <= available }
        return current + spacing + next <= available
    }

    private func advance(current: CGFloat, next: CGFloat) -> CGFloat {
        if current == 0 { return next }
        return current + spacing + next
    }

    private func measureChipWidth(_ text: String, color: Color = .primary) -> CGFloat {
        let ns = text as NSString
        let size = ns.size(withAttributes: [.font: chipFont])
        return ceil(size.width) + hPad * 2
    }
}

