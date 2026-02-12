import SwiftUI

struct RowContextMenuModifier: ViewModifier {
    let shareTitle: String
    let isEnabled: Bool
    let onShare: () -> Void
    let onCopy: () -> Void
    let onAddToCalendar: (() -> Void)?
    let hasReminder: Bool
    let onSetReminder: (() -> Void)?
    let onRemoveReminder: (() -> Void)?
    let onDelete: (() -> Void)?

    func body(content: Content) -> some View {
        Group {
            if isEnabled {
                content
                    .contextMenu {
                        Button(shareTitle) { onShare() }
                        Button("Copy") { onCopy() }

                        if let onAddToCalendar {
                            Button("Add to Calendar") { onAddToCalendar() }
                        }

                        // Nag actions
                        if hasReminder, let onRemoveReminder {
                            Button("Stop nagging me", role: .destructive) {
                                onRemoveReminder()
                            }
                        } else if let onSetReminder {
                            Button("Nag me later") {
                                onSetReminder()
                            }
                        }

                        if let onDelete {
                            Button("Delete", role: .destructive) { onDelete() }
                        }
                    }
            } else {
                content
            }
        }
    }
}

extension View {
    func rowContextMenu(
        shareTitle: String,
        isEnabled: Bool = true,
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
            isEnabled: isEnabled,
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
