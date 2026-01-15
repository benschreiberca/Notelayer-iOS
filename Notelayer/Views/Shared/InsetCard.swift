import SwiftUI

struct InsetCard<Content: View>: View {
    @EnvironmentObject private var theme: ThemeManager
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(theme.tokens.groupFill)
            )
            .background {
                if theme.preset == .cheetah {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.clear)
                        .overlay(CheetahCardPattern().opacity(0.22))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(theme.tokens.cardStroke, lineWidth: 0.5)
            )
    }
}

