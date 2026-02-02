import SwiftUI

struct InsetCard<Content: View>: View {
    enum Role {
        case card
        case group
    }

    @EnvironmentObject private var theme: ThemeManager
    let role: Role
    let content: Content

    init(role: Role = .card, @ViewBuilder content: () -> Content) {
        self.role = role
        self.content = content()
    }

    var body: some View {
        let tokens = theme.tokens.components
        let cardTokens = tokens.card
        let groupTokens = tokens.groupCard
        let background = role == .group ? groupTokens.background : cardTokens.background
        let opacity = role == .group ? groupTokens.opacity : cardTokens.opacity
        let border = role == .group ? groupTokens.border : cardTokens.border
        let borderWidth = role == .group ? groupTokens.borderWidth : cardTokens.borderWidth
        let cornerRadius = role == .group ? groupTokens.cornerRadius : cardTokens.cornerRadius
        content
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(background)
                    .opacity(opacity)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(border, lineWidth: borderWidth)
            )
    }
}
