import SwiftUI

/// Applies presentation detents that read well on both iPhone and iPad.
///
/// On iPhone (compact width) sheets use the supplied detents and behave like
/// the familiar bottom sheet. On iPad (regular width) SwiftUI presents a
/// centered form-sheet card; a `.medium` detent there produces a short card
/// that crops taller content (e.g. the Themes picker). To avoid cropping we
/// promote iPad presentations to a tall fixed fraction and let the card grow.
///
/// Usage:
/// ```swift
/// .sheet(isPresented: $showing) {
///     SomeView()
///         .withThemeAppearance()
///         .adaptiveSheetDetents()
/// }
/// ```
private struct AdaptiveSheetDetents: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    /// Detents used on compact-width (iPhone) presentations.
    let compactDetents: Set<PresentationDetent>

    func body(content: Content) -> some View {
        let isRegular = horizontalSizeClass == .regular
        // On iPad use a tall card so content isn't clipped; on iPhone keep the
        // bottom-sheet detents the call site asked for.
        let detents: Set<PresentationDetent> = isRegular
            ? [.fraction(0.85), .large]
            : compactDetents

        content
            .presentationDetents(detents)
            .presentationDragIndicator(.visible)
    }
}

extension View {
    /// Adaptive detents. `compactDetents` controls iPhone behavior; iPad always
    /// gets a tall card to prevent the centered form-sheet from cropping content.
    func adaptiveSheetDetents(
        compact compactDetents: Set<PresentationDetent> = [.medium, .large]
    ) -> some View {
        modifier(AdaptiveSheetDetents(compactDetents: compactDetents))
    }
}
