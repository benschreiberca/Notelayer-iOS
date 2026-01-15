import SwiftUI

struct NotesView: View {
    @StateObject private var store = LocalStore.shared
    @State private var sharePayload: SharePayload? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(store.notes) { note in
                        InsetCard {
                            Text(note.text)
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .contentShape(Rectangle())
                        .rowContextMenu(
                            shareTitle: "Share…",
                            onShare: {
                                sharePayload = SharePayload(items: [note.text])
                            },
                            onCopy: {
                                UIPasteboard.general.string = note.text
                            }
                        )
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 12)
            }
            .navigationTitle("Notes")
            .onAppear {
                store.load()
            }
            .sheet(item: $sharePayload) { payload in
                ShareSheet(items: payload.items)
            }
        }
    }
}
