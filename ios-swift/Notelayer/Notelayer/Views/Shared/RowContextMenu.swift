import SwiftUI

struct RowContextMenuModifier: ViewModifier {
    let shareTitle: String
    let onShare: () -> Void
    let onCopy: () -> Void
    let onAddToCalendar: (() -> Void)?
    let hasReminder: Bool
    let onSetReminder: (() -> Void)?
    let onRemoveReminder: (() -> Void)?
    let onDelete: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .contextMenu {
                Button("Share…") { onShare() }
                Button("Copy") { onCopy() }
                
                if let onAddToCalendar {
                    Button("Add to Calendar") { onAddToCalendar() }
                }
                
                // Reminder actions
                if hasReminder, let onRemoveReminder {
                    Button("Remove Reminder", role: .destructive) {
                        onRemoveReminder()
                    }
                } else if let onSetReminder {
                    Button("Set Reminder") {
                        onSetReminder()
                    }
                }
                
                if let onDelete {
                    Button("Delete", role: .destructive) { onDelete() }
                }
            }
    }
}

extension View {
    func rowContextMenu(
        shareTitle: String,
        onShare: @escaping () -> Void,
        onCopy: @escaping () -> Void,
        onAddToCalendar: (() -> Void)? = nil,
        hasReminder: Bool = false,
        onSetReminder: (() -> Void)? = nil,
        onRemoveReminder: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil
    ) -> some View {
        modifier(RowContextMenuModifier(
            shareTitle: shareTitle,
            onShare: onShare,
            onCopy: onCopy,
            onAddToCalendar: onAddToCalendar,
            hasReminder: hasReminder,
            onSetReminder: onSetReminder,
            onRemoveReminder: onRemoveReminder,
            onDelete: onDelete
        ))
    }
}
