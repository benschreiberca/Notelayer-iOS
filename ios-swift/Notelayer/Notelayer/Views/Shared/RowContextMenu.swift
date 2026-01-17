import SwiftUI

struct RowContextMenuModifier: ViewModifier {
    let shareTitle: String
    let onShare: () -> Void
    let onCopy: () -> Void

    func body(content: Content) -> some View {
        content
            .contextMenu {
                Button("Share…") { onShare() }
                Button("Copy") { onCopy() }
                Button("Cancel", role: .cancel) {}
            }
    }
}

extension View {
    func rowContextMenu(shareTitle: String, onShare: @escaping () -> Void, onCopy: @escaping () -> Void) -> some View {
        modifier(RowContextMenuModifier(shareTitle: shareTitle, onShare: onShare, onCopy: onCopy))
    }
}

