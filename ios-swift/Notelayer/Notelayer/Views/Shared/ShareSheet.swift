import SwiftUI

struct SharePayload: Identifiable {
    let id = UUID()
    let items: [Any]
}

#if os(iOS)
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#else

/// macOS: copy strings to clipboard; reveal URLs/files in Finder.
struct ShareSheet: View {
    let items: [Any]

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.and.arrow.up")
                .font(.largeTitle)
                .foregroundColor(.accentColor)

            if let text = items.compactMap({ $0 as? String }).first {
                Text("Copied to clipboard")
                    .font(.headline)
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
                    .onAppear {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(text, forType: .string)
                    }
            } else if let url = items.compactMap({ $0 as? URL }).first {
                Text("File ready to share")
                    .font(.headline)
                Text(url.lastPathComponent)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Button("Reveal in Finder") {
                    NSWorkspace.shared.activateFileViewerSelecting([url])
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(32)
        .frame(minWidth: 320)
    }
}

#endif
