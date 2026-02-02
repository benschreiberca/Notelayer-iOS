import SwiftUI

// MARK: - Primitive Tokens

/// Raw, brand-agnostic values. These never change by theme or mode.
struct PrimitiveTokens {
    struct Colors {
        // Grays
        static let gray50 = Color(hex: "#F9FAFB") ?? .white
        static let gray100 = Color(hex: "#F3F4F6") ?? .white
        static let gray200 = Color(hex: "#E5E7EB") ?? .white
        static let gray300 = Color(hex: "#D1D5DB") ?? .gray
        static let gray400 = Color(hex: "#9CA3AF") ?? .gray
        static let gray500 = Color(hex: "#6B7280") ?? .gray
        static let gray600 = Color(hex: "#4B5563") ?? .gray
        static let gray700 = Color(hex: "#374151") ?? .gray
        static let gray800 = Color(hex: "#1F2937") ?? .black
        static let gray900 = Color(hex: "#111827") ?? .black

        // Brand scales (subset used in defaults)
        static let indigo50 = Color(hex: "#EEF2FF") ?? .blue
        static let indigo300 = Color(hex: "#A5B4FC") ?? .blue
        static let indigo400 = Color(hex: "#818CF8") ?? .blue
        static let indigo500 = Color(hex: "#6366F1") ?? .blue
        static let indigo600 = Color(hex: "#4F46E5") ?? .blue
        static let indigo700 = Color(hex: "#4338CA") ?? .blue

        static let purple400 = Color(hex: "#C084FC") ?? .purple
        static let purple500 = Color(hex: "#A855F7") ?? .purple

        static let pink400 = Color(hex: "#F472B6") ?? .pink
        static let pink500 = Color(hex: "#EC4899") ?? .pink

        static let blue400 = Color(hex: "#60A5FA") ?? .blue
        static let blue600 = Color(hex: "#2563EB") ?? .blue

        static let green400 = Color(hex: "#4ADE80") ?? .green
        static let green600 = Color(hex: "#16A34A") ?? .green
        static let green50 = Color(hex: "#F0FDF4") ?? .green
        static let green900 = Color(hex: "#14532D") ?? .green

        static let amber400 = Color(hex: "#FBBF24") ?? .orange
        static let amber600 = Color(hex: "#D97706") ?? .orange
        static let amber50 = Color(hex: "#FFFBEB") ?? .orange
        static let amber900 = Color(hex: "#78350F") ?? .orange

        static let red400 = Color(hex: "#F87171") ?? .red
        static let red600 = Color(hex: "#DC2626") ?? .red
        static let red50 = Color(hex: "#FEF2F2") ?? .red
        static let red900 = Color(hex: "#7F1D1D") ?? .red
    }

    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    struct Typography {
        static let fontSize10: CGFloat = 10
        static let fontSize12: CGFloat = 12
        static let fontSize14: CGFloat = 14
        static let fontSize16: CGFloat = 16
        static let fontSize20: CGFloat = 20
        static let fontSize24: CGFloat = 24
        static let fontSize32: CGFloat = 32
    }

    struct Radius {
        static let none: CGFloat = 0
        static let sm: CGFloat = 4
        static let md: CGFloat = 8
        static let lg: CGFloat = 12
        static let xl: CGFloat = 16
        static let full: CGFloat = 9999
    }

    struct Shadows {
        static let sm = (radius: 2.0, x: 0.0, y: 1.0)
        static let md = (radius: 4.0, x: 0.0, y: 2.0)
        static let lg = (radius: 8.0, x: 0.0, y: 4.0)
        static let xl = (radius: 16.0, x: 0.0, y: 8.0)
    }

    struct Opacity {
        static let transparent: Double = 0.0
        static let subtle: Double = 0.05
        static let light: Double = 0.1
        static let medium: Double = 0.3
        static let heavy: Double = 0.6
        static let opaque: Double = 1.0
    }
}

// MARK: - Typography + Shadow Styles

struct TypographyStyle {
    let font: Font
    let size: CGFloat
    let weight: Font.Weight
    let lineHeight: CGFloat
    let letterSpacing: CGFloat
}

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Surface Tinting

/// Strength values for tinting each surface tier. Higher values apply more accent hue.
struct SurfaceTintStrengths {
    let background: Double
    let group: Double
    let card: Double

    var clamped: SurfaceTintStrengths {
        SurfaceTintStrengths(
            background: min(max(background, 0.0), 1.0),
            group: min(max(group, 0.0), 1.0),
            card: min(max(card, 0.0), 1.0)
        )
    }

    static let zero = SurfaceTintStrengths(background: 0.0, group: 0.0, card: 0.0)

    static let subtleLight = SurfaceTintStrengths(background: 0.04, group: 0.08, card: 0.12)
    static let subtleDark = SurfaceTintStrengths(background: 0.06, group: 0.10, card: 0.14)

    static let mediumLight = SurfaceTintStrengths(background: 0.06, group: 0.10, card: 0.14)
    static let mediumDark = SurfaceTintStrengths(background: 0.08, group: 0.12, card: 0.16)

    static let boldLight = SurfaceTintStrengths(background: 0.08, group: 0.12, card: 0.16)
    static let boldDark = SurfaceTintStrengths(background: 0.10, group: 0.14, card: 0.18)
}

/// Base neutral ladder for surfaces. This preserves the lightness hierarchy before tinting.
struct SurfaceBaseLadder {
    let background: Color
    let group: Color
    let card: Color

    static let defaultLight = SurfaceBaseLadder(
        background: PrimitiveTokens.Colors.gray100,
        group: PrimitiveTokens.Colors.gray50,
        card: .white
    )

    static let defaultDark = SurfaceBaseLadder(
        background: PrimitiveTokens.Colors.gray900,
        group: PrimitiveTokens.Colors.gray800,
        card: PrimitiveTokens.Colors.gray700
    )

    static let whiteCardsLight = SurfaceBaseLadder(
        background: PrimitiveTokens.Colors.gray200,
        group: PrimitiveTokens.Colors.gray100,
        card: .white
    )

    static let whiteCardsDark = SurfaceBaseLadder(
        background: PrimitiveTokens.Colors.gray900,
        group: PrimitiveTokens.Colors.gray800,
        card: PrimitiveTokens.Colors.gray700
    )
}

enum SurfaceTintStyle {
    case subtle
    case medium
    case bold

    var lightStrengths: SurfaceTintStrengths {
        switch self {
        case .subtle: return .subtleLight
        case .medium: return .mediumLight
        case .bold: return .boldLight
        }
    }

    var darkStrengths: SurfaceTintStrengths {
        switch self {
        case .subtle: return .subtleDark
        case .medium: return .mediumDark
        case .bold: return .boldDark
        }
    }
}

/// Theme-level surface tint configuration (Option B).
struct SurfaceTintingDefinition {
    let lightBase: SurfaceBaseLadder
    let darkBase: SurfaceBaseLadder
    let lightStrengths: SurfaceTintStrengths
    let darkStrengths: SurfaceTintStrengths

    static func tinted(style: SurfaceTintStyle) -> SurfaceTintingDefinition {
        SurfaceTintingDefinition(
            lightBase: .defaultLight,
            darkBase: .defaultDark,
            lightStrengths: style.lightStrengths,
            darkStrengths: style.darkStrengths
        )
    }

    /// Neutral ladder for the one theme with pure-white task cards (no tinting).
    static let whiteCardsNeutral = SurfaceTintingDefinition(
        lightBase: .whiteCardsLight,
        darkBase: .whiteCardsDark,
        lightStrengths: .zero,
        darkStrengths: .zero
    )
}

// MARK: - Semantic Tokens

/// Semantic meaning applied to primitives. These are theme + mode specific.
struct SemanticTokens {
    let mode: ColorScheme

    // Brand & identity
    var brandPrimary: Color
    var brandSecondary: Color
    var brandTertiary: Color

    // Interactive
    var interactivePrimary: Color
    var interactivePrimaryHover: Color
    var interactivePrimaryActive: Color
    var interactivePrimaryDisabled: Color

    var interactiveSecondary: Color
    var interactiveSecondaryHover: Color
    var interactiveSecondaryActive: Color

    // Backgrounds
    var backgroundBase: Color
    var backgroundElevated1: Color
    var backgroundElevated2: Color
    var backgroundElevated3: Color

    var backgroundSubtle: Color
    var backgroundInverse: Color

    // Borders
    var borderDefault: Color
    var borderSubtle: Color
    var borderStrong: Color
    var borderFocus: Color

    // Text
    var textPrimary: Color
    var textSecondary: Color
    var textTertiary: Color
    var textDisabled: Color
    var textInverse: Color
    var textOnInteractive: Color
    var textLink: Color

    // Status
    var statusSuccess: Color
    var statusSuccessSubtle: Color
    var statusWarning: Color
    var statusWarningSubtle: Color
    var statusError: Color
    var statusErrorSubtle: Color
    var statusInfo: Color
    var statusInfoSubtle: Color

    // Overlays
    var overlayLight: Color
    var overlayDark: Color
    var scrim: Color

    // Spacing
    var spacingInline: CGFloat
    var spacingStack: CGFloat
    var spacingInset: CGFloat
    var spacingSection: CGFloat
    var spacingPage: CGFloat

    // Typography
    var typographyDisplayLarge: TypographyStyle
    var typographyDisplayMedium: TypographyStyle
    var typographyHeadingLarge: TypographyStyle
    var typographyHeadingMedium: TypographyStyle
    var typographyHeadingSmall: TypographyStyle
    var typographyBodyLarge: TypographyStyle
    var typographyBodyMedium: TypographyStyle
    var typographyBodySmall: TypographyStyle
    var typographyLabelLarge: TypographyStyle
    var typographyLabelMedium: TypographyStyle
    var typographyLabelSmall: TypographyStyle
    var typographyCode: TypographyStyle

    // Effects
    var shadowSubtle: ShadowStyle
    var shadowModerate: ShadowStyle
    var shadowStrong: ShadowStyle

    var blurSubtle: CGFloat
    var blurModerate: CGFloat
    var blurStrong: CGFloat

    /// Apply a primary + secondary accent to a semantic palette.
    func applyingAccent(primary: Color, secondary: Color) -> SemanticTokens {
        var updated = self
        updated.brandPrimary = primary
        updated.brandSecondary = secondary
        updated.interactivePrimary = primary
        updated.interactivePrimaryHover = primary.opacity(mode == .light ? 0.85 : 0.9)
        updated.interactivePrimaryActive = primary.opacity(mode == .light ? 0.7 : 0.8)
        updated.borderFocus = primary
        updated.textLink = primary
        return updated
    }

    /// Apply surface tinting using the configured base ladder and strengths.
    /// This preserves the background -> group -> card lightness hierarchy while introducing hue.
    func applyingSurfaceTint(accent: Color, base: SurfaceBaseLadder, strengths: SurfaceTintStrengths) -> SemanticTokens {
        let clamped = strengths.clamped
        let background = base.background.blended(with: accent, amount: clamped.background)
        let group = base.group.blended(with: accent, amount: clamped.group)
        let card = base.card.blended(with: accent, amount: clamped.card)

        var updated = self
        updated.backgroundBase = background
        updated.backgroundElevated1 = group
        updated.backgroundElevated2 = card
        updated.backgroundElevated3 = card
        updated.backgroundSubtle = group
        return updated
    }
}

extension SemanticTokens {
    static func defaultLight() -> SemanticTokens {
        SemanticTokens(
            mode: .light,
            brandPrimary: PrimitiveTokens.Colors.indigo500,
            brandSecondary: PrimitiveTokens.Colors.purple500,
            brandTertiary: PrimitiveTokens.Colors.pink500,
            interactivePrimary: PrimitiveTokens.Colors.indigo500,
            interactivePrimaryHover: PrimitiveTokens.Colors.indigo600,
            interactivePrimaryActive: PrimitiveTokens.Colors.indigo700,
            interactivePrimaryDisabled: PrimitiveTokens.Colors.gray300,
            interactiveSecondary: PrimitiveTokens.Colors.indigo500,
            interactiveSecondaryHover: PrimitiveTokens.Colors.indigo600,
            interactiveSecondaryActive: PrimitiveTokens.Colors.indigo700,
            backgroundBase: PrimitiveTokens.Colors.gray50,
            backgroundElevated1: Color.white,
            backgroundElevated2: PrimitiveTokens.Colors.gray50,
            backgroundElevated3: Color.white,
            backgroundSubtle: PrimitiveTokens.Colors.gray100,
            backgroundInverse: PrimitiveTokens.Colors.gray900,
            borderDefault: PrimitiveTokens.Colors.gray200,
            borderSubtle: PrimitiveTokens.Colors.gray100,
            borderStrong: PrimitiveTokens.Colors.gray300,
            borderFocus: PrimitiveTokens.Colors.indigo500,
            textPrimary: PrimitiveTokens.Colors.gray900,
            textSecondary: PrimitiveTokens.Colors.gray600,
            textTertiary: PrimitiveTokens.Colors.gray500,
            textDisabled: PrimitiveTokens.Colors.gray400,
            textInverse: .white,
            textOnInteractive: .white,
            textLink: PrimitiveTokens.Colors.indigo500,
            statusSuccess: PrimitiveTokens.Colors.green600,
            statusSuccessSubtle: PrimitiveTokens.Colors.green50,
            statusWarning: PrimitiveTokens.Colors.amber600,
            statusWarningSubtle: PrimitiveTokens.Colors.amber50,
            statusError: PrimitiveTokens.Colors.red600,
            statusErrorSubtle: PrimitiveTokens.Colors.red50,
            statusInfo: PrimitiveTokens.Colors.blue600,
            statusInfoSubtle: PrimitiveTokens.Colors.blue400,
            overlayLight: Color.black.opacity(PrimitiveTokens.Opacity.medium),
            overlayDark: Color.black.opacity(PrimitiveTokens.Opacity.heavy),
            scrim: Color.black.opacity(PrimitiveTokens.Opacity.heavy),
            spacingInline: PrimitiveTokens.Spacing.sm,
            spacingStack: PrimitiveTokens.Spacing.md,
            spacingInset: PrimitiveTokens.Spacing.md,
            spacingSection: PrimitiveTokens.Spacing.xl,
            spacingPage: PrimitiveTokens.Spacing.lg,
            typographyDisplayLarge: TypographyStyle(
                font: .system(size: PrimitiveTokens.Typography.fontSize32, weight: .bold),
                size: PrimitiveTokens.Typography.fontSize32,
                weight: .bold,
                lineHeight: 40,
                letterSpacing: -0.5
            ),
            typographyDisplayMedium: TypographyStyle(
                font: .system(size: PrimitiveTokens.Typography.fontSize24, weight: .bold),
                size: PrimitiveTokens.Typography.fontSize24,
                weight: .bold,
                lineHeight: 32,
                letterSpacing: -0.3
            ),
            typographyHeadingLarge: TypographyStyle(
                font: .system(size: PrimitiveTokens.Typography.fontSize20, weight: .semibold),
                size: PrimitiveTokens.Typography.fontSize20,
                weight: .semibold,
                lineHeight: 28,
                letterSpacing: -0.2
            ),
            typographyHeadingMedium: TypographyStyle(
                font: .system(size: PrimitiveTokens.Typography.fontSize16, weight: .semibold),
                size: PrimitiveTokens.Typography.fontSize16,
                weight: .semibold,
                lineHeight: 22,
                letterSpacing: -0.1
            ),
            typographyHeadingSmall: TypographyStyle(
                font: .system(size: PrimitiveTokens.Typography.fontSize14, weight: .semibold),
                size: PrimitiveTokens.Typography.fontSize14,
                weight: .semibold,
                lineHeight: 20,
                letterSpacing: 0
            ),
            typographyBodyLarge: TypographyStyle(
                font: .system(size: PrimitiveTokens.Typography.fontSize16, weight: .regular),
                size: PrimitiveTokens.Typography.fontSize16,
                weight: .regular,
                lineHeight: 24,
                letterSpacing: 0
            ),
            typographyBodyMedium: TypographyStyle(
                font: .system(size: PrimitiveTokens.Typography.fontSize14, weight: .regular),
                size: PrimitiveTokens.Typography.fontSize14,
                weight: .regular,
                lineHeight: 20,
                letterSpacing: 0
            ),
            typographyBodySmall: TypographyStyle(
                font: .system(size: PrimitiveTokens.Typography.fontSize12, weight: .regular),
                size: PrimitiveTokens.Typography.fontSize12,
                weight: .regular,
                lineHeight: 18,
                letterSpacing: 0
            ),
            typographyLabelLarge: TypographyStyle(
                font: .system(size: PrimitiveTokens.Typography.fontSize14, weight: .medium),
                size: PrimitiveTokens.Typography.fontSize14,
                weight: .medium,
                lineHeight: 18,
                letterSpacing: 0
            ),
            typographyLabelMedium: TypographyStyle(
                font: .system(size: PrimitiveTokens.Typography.fontSize12, weight: .medium),
                size: PrimitiveTokens.Typography.fontSize12,
                weight: .medium,
                lineHeight: 16,
                letterSpacing: 0
            ),
            typographyLabelSmall: TypographyStyle(
                font: .system(size: PrimitiveTokens.Typography.fontSize10, weight: .medium),
                size: PrimitiveTokens.Typography.fontSize10,
                weight: .medium,
                lineHeight: 14,
                letterSpacing: 0
            ),
            typographyCode: TypographyStyle(
                font: .system(size: PrimitiveTokens.Typography.fontSize12, weight: .regular, design: .monospaced),
                size: PrimitiveTokens.Typography.fontSize12,
                weight: .regular,
                lineHeight: 16,
                letterSpacing: 0
            ),
            shadowSubtle: ShadowStyle(
                color: Color.black.opacity(0.05),
                radius: PrimitiveTokens.Shadows.sm.radius,
                x: PrimitiveTokens.Shadows.sm.x,
                y: PrimitiveTokens.Shadows.sm.y
            ),
            shadowModerate: ShadowStyle(
                color: Color.black.opacity(0.08),
                radius: PrimitiveTokens.Shadows.md.radius,
                x: PrimitiveTokens.Shadows.md.x,
                y: PrimitiveTokens.Shadows.md.y
            ),
            shadowStrong: ShadowStyle(
                color: Color.black.opacity(0.12),
                radius: PrimitiveTokens.Shadows.lg.radius,
                x: PrimitiveTokens.Shadows.lg.x,
                y: PrimitiveTokens.Shadows.lg.y
            ),
            blurSubtle: 4,
            blurModerate: 8,
            blurStrong: 16
        )
    }

    static func defaultDark() -> SemanticTokens {
        SemanticTokens(
            mode: .dark,
            brandPrimary: PrimitiveTokens.Colors.indigo400,
            brandSecondary: PrimitiveTokens.Colors.purple400,
            brandTertiary: PrimitiveTokens.Colors.pink400,
            interactivePrimary: PrimitiveTokens.Colors.indigo400,
            interactivePrimaryHover: PrimitiveTokens.Colors.indigo300,
            interactivePrimaryActive: PrimitiveTokens.Colors.indigo300,
            interactivePrimaryDisabled: PrimitiveTokens.Colors.gray600,
            interactiveSecondary: PrimitiveTokens.Colors.indigo400,
            interactiveSecondaryHover: PrimitiveTokens.Colors.indigo300,
            interactiveSecondaryActive: PrimitiveTokens.Colors.indigo300,
            backgroundBase: PrimitiveTokens.Colors.gray900,
            backgroundElevated1: PrimitiveTokens.Colors.gray800,
            backgroundElevated2: PrimitiveTokens.Colors.gray700,
            backgroundElevated3: PrimitiveTokens.Colors.gray600,
            backgroundSubtle: PrimitiveTokens.Colors.gray800,
            backgroundInverse: .white,
            borderDefault: PrimitiveTokens.Colors.gray700,
            borderSubtle: PrimitiveTokens.Colors.gray800,
            borderStrong: PrimitiveTokens.Colors.gray600,
            borderFocus: PrimitiveTokens.Colors.indigo400,
            textPrimary: .white,
            textSecondary: PrimitiveTokens.Colors.gray300,
            textTertiary: PrimitiveTokens.Colors.gray400,
            textDisabled: PrimitiveTokens.Colors.gray600,
            textInverse: PrimitiveTokens.Colors.gray900,
            textOnInteractive: PrimitiveTokens.Colors.gray900,
            textLink: PrimitiveTokens.Colors.indigo400,
            statusSuccess: PrimitiveTokens.Colors.green400,
            statusSuccessSubtle: PrimitiveTokens.Colors.green900,
            statusWarning: PrimitiveTokens.Colors.amber400,
            statusWarningSubtle: PrimitiveTokens.Colors.amber900,
            statusError: PrimitiveTokens.Colors.red400,
            statusErrorSubtle: PrimitiveTokens.Colors.red900,
            statusInfo: PrimitiveTokens.Colors.blue400,
            statusInfoSubtle: PrimitiveTokens.Colors.blue600,
            overlayLight: Color.white.opacity(PrimitiveTokens.Opacity.light),
            overlayDark: Color.black.opacity(PrimitiveTokens.Opacity.heavy),
            scrim: Color.black.opacity(PrimitiveTokens.Opacity.opaque),
            spacingInline: PrimitiveTokens.Spacing.sm,
            spacingStack: PrimitiveTokens.Spacing.md,
            spacingInset: PrimitiveTokens.Spacing.md,
            spacingSection: PrimitiveTokens.Spacing.xl,
            spacingPage: PrimitiveTokens.Spacing.lg,
            typographyDisplayLarge: TypographyStyle(
                font: .system(size: PrimitiveTokens.Typography.fontSize32, weight: .bold),
                size: PrimitiveTokens.Typography.fontSize32,
                weight: .bold,
                lineHeight: 40,
                letterSpacing: -0.5
            ),
            typographyDisplayMedium: TypographyStyle(
                font: .system(size: PrimitiveTokens.Typography.fontSize24, weight: .bold),
                size: PrimitiveTokens.Typography.fontSize24,
                weight: .bold,
                lineHeight: 32,
                letterSpacing: -0.3
            ),
            typographyHeadingLarge: TypographyStyle(
                font: .system(size: PrimitiveTokens.Typography.fontSize20, weight: .semibold),
                size: PrimitiveTokens.Typography.fontSize20,
                weight: .semibold,
                lineHeight: 28,
                letterSpacing: -0.2
            ),
            typographyHeadingMedium: TypographyStyle(
                font: .system(size: PrimitiveTokens.Typography.fontSize16, weight: .semibold),
                size: PrimitiveTokens.Typography.fontSize16,
                weight: .semibold,
                lineHeight: 22,
                letterSpacing: -0.1
            ),
            typographyHeadingSmall: TypographyStyle(
                font: .system(size: PrimitiveTokens.Typography.fontSize14, weight: .semibold),
                size: PrimitiveTokens.Typography.fontSize14,
                weight: .semibold,
                lineHeight: 20,
                letterSpacing: 0
            ),
            typographyBodyLarge: TypographyStyle(
                font: .system(size: PrimitiveTokens.Typography.fontSize16, weight: .regular),
                size: PrimitiveTokens.Typography.fontSize16,
                weight: .regular,
                lineHeight: 24,
                letterSpacing: 0
            ),
            typographyBodyMedium: TypographyStyle(
                font: .system(size: PrimitiveTokens.Typography.fontSize14, weight: .regular),
                size: PrimitiveTokens.Typography.fontSize14,
                weight: .regular,
                lineHeight: 20,
                letterSpacing: 0
            ),
            typographyBodySmall: TypographyStyle(
                font: .system(size: PrimitiveTokens.Typography.fontSize12, weight: .regular),
                size: PrimitiveTokens.Typography.fontSize12,
                weight: .regular,
                lineHeight: 18,
                letterSpacing: 0
            ),
            typographyLabelLarge: TypographyStyle(
                font: .system(size: PrimitiveTokens.Typography.fontSize14, weight: .medium),
                size: PrimitiveTokens.Typography.fontSize14,
                weight: .medium,
                lineHeight: 18,
                letterSpacing: 0
            ),
            typographyLabelMedium: TypographyStyle(
                font: .system(size: PrimitiveTokens.Typography.fontSize12, weight: .medium),
                size: PrimitiveTokens.Typography.fontSize12,
                weight: .medium,
                lineHeight: 16,
                letterSpacing: 0
            ),
            typographyLabelSmall: TypographyStyle(
                font: .system(size: PrimitiveTokens.Typography.fontSize10, weight: .medium),
                size: PrimitiveTokens.Typography.fontSize10,
                weight: .medium,
                lineHeight: 14,
                letterSpacing: 0
            ),
            typographyCode: TypographyStyle(
                font: .system(size: PrimitiveTokens.Typography.fontSize12, weight: .regular, design: .monospaced),
                size: PrimitiveTokens.Typography.fontSize12,
                weight: .regular,
                lineHeight: 16,
                letterSpacing: 0
            ),
            shadowSubtle: ShadowStyle(
                color: Color.black.opacity(0.3),
                radius: PrimitiveTokens.Shadows.sm.radius,
                x: PrimitiveTokens.Shadows.sm.x,
                y: PrimitiveTokens.Shadows.sm.y
            ),
            shadowModerate: ShadowStyle(
                color: Color.black.opacity(0.4),
                radius: PrimitiveTokens.Shadows.md.radius,
                x: PrimitiveTokens.Shadows.md.x,
                y: PrimitiveTokens.Shadows.md.y
            ),
            shadowStrong: ShadowStyle(
                color: Color.black.opacity(0.5),
                radius: PrimitiveTokens.Shadows.lg.radius,
                x: PrimitiveTokens.Shadows.lg.x,
                y: PrimitiveTokens.Shadows.lg.y
            ),
            blurSubtle: 4,
            blurModerate: 8,
            blurStrong: 16
        )
    }
}

// MARK: - Color Utilities

extension Color {
    /// Blend this color with an overlay color by the given amount (0 = base, 1 = overlay).
    func blended(with overlay: Color, amount: Double) -> Color {
        #if canImport(UIKit)
        let clamped = min(max(amount, 0.0), 1.0)
        let base = UIColor(self)
        let overlayColor = UIColor(overlay)
        var r1: CGFloat = 0
        var g1: CGFloat = 0
        var b1: CGFloat = 0
        var a1: CGFloat = 0
        var r2: CGFloat = 0
        var g2: CGFloat = 0
        var b2: CGFloat = 0
        var a2: CGFloat = 0
        guard base.getRed(&r1, green: &g1, blue: &b1, alpha: &a1),
              overlayColor.getRed(&r2, green: &g2, blue: &b2, alpha: &a2) else {
            return self
        }
        let r = r1 + (r2 - r1) * CGFloat(clamped)
        let g = g1 + (g2 - g1) * CGFloat(clamped)
        let b = b1 + (b2 - b1) * CGFloat(clamped)
        let a = a1 + (a2 - a1) * CGFloat(clamped)
        return Color(red: Double(r), green: Double(g), blue: Double(b), opacity: Double(a))
        #else
        return self
        #endif
    }
}

// MARK: - Component Tokens

/// Component-specific styles derived from semantic tokens.
struct ComponentTokens {
    let semantic: SemanticTokens
    let surfaceStyle: ThemeSurfaceStyle
    let surfaceOpacity: Double
    let overrides: ComponentOverrides?

    var button: ButtonTokens { ButtonTokens(semantic: semantic, overrides: overrides) }
    var card: CardTokens { CardTokens(semantic: semantic, surfaceStyle: surfaceStyle, surfaceOpacity: surfaceOpacity, overrides: overrides) }
    var groupCard: GroupCardTokens { GroupCardTokens(semantic: semantic, surfaceStyle: surfaceStyle, surfaceOpacity: surfaceOpacity, overrides: overrides) }
    var taskItem: TaskItemTokens { TaskItemTokens(semantic: semantic, surfaceStyle: surfaceStyle, surfaceOpacity: surfaceOpacity, overrides: overrides) }
    var badge: BadgeTokens { BadgeTokens(semantic: semantic) }
    var groupHeader: GroupHeaderTokens { GroupHeaderTokens(semantic: semantic) }

    // MARK: - Button
    struct ButtonTokens {
        let semantic: SemanticTokens
        let overrides: ComponentOverrides?

        var primaryBackground: AnyShapeStyle {
            if let override = overrides?.buttonPrimaryBackground {
                return override(semantic)
            }
            return AnyShapeStyle(semantic.interactivePrimary)
        }

        var primaryText: Color { semantic.textOnInteractive }
        var primaryCornerRadius: CGFloat { PrimitiveTokens.Radius.md }
        var primaryShadow: ShadowStyle { semantic.shadowSubtle }

        var secondaryBackground: Color { .clear }
        var secondaryText: Color { semantic.interactivePrimary }
        var secondaryBorder: Color { semantic.borderDefault }
    }

    // MARK: - Card
    struct CardTokens {
        let semantic: SemanticTokens
        let surfaceStyle: ThemeSurfaceStyle
        let surfaceOpacity: Double
        let overrides: ComponentOverrides?

        var background: AnyShapeStyle {
            if let override = overrides?.cardBackground {
                return override(semantic)
            }
            switch surfaceStyle {
            case .soft:
                return AnyShapeStyle(
                    LinearGradient(
                        colors: [semantic.backgroundElevated2, semantic.backgroundElevated1.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            case .frosted:
                // Use tinted solids so light presets still show the surface ladder clearly.
                return AnyShapeStyle(semantic.backgroundElevated2)
            case .gradient:
                return AnyShapeStyle(
                    LinearGradient(
                        colors: [semantic.backgroundElevated2, semantic.backgroundElevated1, semantic.backgroundElevated2],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            case .solid:
                return AnyShapeStyle(semantic.backgroundElevated2)
            }
        }

        var opacity: Double { surfaceOpacity }
        var border: Color { semantic.borderSubtle }
        var borderWidth: CGFloat { 0.5 }
        var cornerRadius: CGFloat { PrimitiveTokens.Radius.lg }
    }

    // MARK: - Group Card
    struct GroupCardTokens {
        let semantic: SemanticTokens
        let surfaceStyle: ThemeSurfaceStyle
        let surfaceOpacity: Double
        let overrides: ComponentOverrides?

        var background: AnyShapeStyle {
            if let override = overrides?.groupBackground {
                return override(semantic)
            }
            switch surfaceStyle {
            case .soft:
                return AnyShapeStyle(
                    LinearGradient(
                        colors: [semantic.backgroundElevated1, semantic.backgroundBase.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            case .frosted:
                // Use tinted solids so light presets still show the surface ladder clearly.
                return AnyShapeStyle(semantic.backgroundElevated1)
            case .gradient:
                return AnyShapeStyle(
                    LinearGradient(
                        colors: [semantic.backgroundElevated1, semantic.backgroundBase, semantic.backgroundElevated1],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            case .solid:
                return AnyShapeStyle(semantic.backgroundElevated1)
            }
        }

        var opacity: Double { surfaceOpacity }
        var border: Color { semantic.borderSubtle }
        var borderWidth: CGFloat { 0.5 }
        var cornerRadius: CGFloat { PrimitiveTokens.Radius.lg }
    }

    // MARK: - Task Item
    struct TaskItemTokens {
        let semantic: SemanticTokens
        let surfaceStyle: ThemeSurfaceStyle
        let surfaceOpacity: Double
        let overrides: ComponentOverrides?

        var background: AnyShapeStyle {
            if let override = overrides?.taskBackground {
                return override(semantic)
            }
            switch surfaceStyle {
            case .soft:
                return AnyShapeStyle(
                    LinearGradient(
                        colors: [semantic.backgroundElevated2, semantic.backgroundElevated1.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            case .frosted:
                // Use tinted solids so light presets still show the surface ladder clearly.
                return AnyShapeStyle(semantic.backgroundElevated2)
            case .gradient:
                return AnyShapeStyle(
                    LinearGradient(
                        colors: [semantic.backgroundElevated2, semantic.backgroundElevated1, semantic.backgroundElevated2],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            case .solid:
                return AnyShapeStyle(semantic.backgroundElevated2)
            }
        }

        var opacity: Double { surfaceOpacity }
        var border: Color { semantic.borderSubtle }
        var borderWidth: CGFloat { 0.5 }
        var cornerRadius: CGFloat { PrimitiveTokens.Radius.md }
        var titleText: Color { semantic.textPrimary }
        var titleCompletedText: Color { semantic.textTertiary }
        var metaText: Color { semantic.textSecondary }
    }

    // MARK: - Badge
    struct BadgeTokens {
        let semantic: SemanticTokens

        var selectedBackground: Color { semantic.interactivePrimary.opacity(0.18) }
        var selectedBorder: Color { .clear }
        var unselectedBackground: Color { .clear }
        var unselectedBorder: Color { semantic.interactivePrimary }
        var text: Color { semantic.textSecondary }
        var cornerRadius: CGFloat { PrimitiveTokens.Radius.full }
    }

    // MARK: - Group Header
    struct GroupHeaderTokens {
        let semantic: SemanticTokens

        var titleText: Color { semantic.textPrimary }
        var countBackground: Color { semantic.brandSecondary.opacity(0.16) }
        var countText: Color { semantic.brandSecondary }
        var chevron: Color { semantic.textSecondary }
    }
}

// MARK: - Component Overrides

/// Optional hooks to override component styling per theme.
struct ComponentOverrides {
    var buttonPrimaryBackground: ((SemanticTokens) -> AnyShapeStyle)?
    var cardBackground: ((SemanticTokens) -> AnyShapeStyle)?
    var groupBackground: ((SemanticTokens) -> AnyShapeStyle)?
    var taskBackground: ((SemanticTokens) -> AnyShapeStyle)?
}

// MARK: - Wallpaper Definitions

enum GradientType: String, Equatable {
    case linear
    case radial
    case angular
}

struct GradientConfiguration: Equatable {
    let type: GradientType
}

struct PatternVariant: Equatable {
    let id: String
    let backgroundHex: String
    let foregroundHex: String
}

struct GradientVariant: Equatable {
    let colors: [String]
    let configuration: GradientConfiguration
}

struct WallpaperVariant: Equatable {
    var gradient: GradientVariant?
    var pattern: PatternVariant?
    var designer: PatternVariant?
    var imageName: String?
}

struct WallpaperDefinition: Identifiable, Equatable {
    let id: String
    let name: String
    let type: ThemeWallpaperKind
    let lightVariant: WallpaperVariant
    let darkVariant: WallpaperVariant
}

// MARK: - Theme Definition

struct ThemeDefinition: Identifiable {
    let id: String
    let name: String
    let description: String
    let category: ThemePresetCategory
    let preferredMode: ThemeMode
    let lightSemanticTokens: SemanticTokens
    let darkSemanticTokens: SemanticTokens
    let defaultConfiguration: ThemeConfiguration
    let surfaceTinting: SurfaceTintingDefinition
    let componentOverrides: ComponentOverrides?
}

// MARK: - Design Tokens (Unified Access)

struct DesignTokens {
    let theme: ThemeDefinition
    let configuration: ThemeConfiguration
    let resolvedMode: ColorScheme

    var semantic: SemanticTokens {
        let base = resolvedMode == .dark ? theme.darkSemanticTokens : theme.lightSemanticTokens
        let accentColor = configuration.accent.color
        // Keep section tint in concert with accent by gently harmonizing hues.
        let harmonizedSection = configuration.sectionTint.color.blended(with: accentColor, amount: 0.35)
        let accentApplied = base.applyingAccent(primary: accentColor, secondary: harmonizedSection)

        let tinting = theme.surfaceTinting
        let baseLadder = resolvedMode == .dark ? tinting.darkBase : tinting.lightBase
        let strengths = resolvedMode == .dark ? tinting.darkStrengths : tinting.lightStrengths
        return accentApplied.applyingSurfaceTint(accent: accentColor, base: baseLadder, strengths: strengths)
    }

    var components: ComponentTokens {
        ComponentTokens(
            semantic: semantic,
            surfaceStyle: configuration.surfaceStyle,
            surfaceOpacity: configuration.surfaceOpacity,
            overrides: theme.componentOverrides
        )
    }

    var wallpaper: WallpaperVariant {
        let definition = configuration.wallpaper.definition
        return resolvedMode == .dark ? definition.darkVariant : definition.lightVariant
    }

    // Convenience accessors for app-wide uses
    var accent: Color { semantic.interactivePrimary }
    var sectionTint: Color { semantic.brandSecondary }
    var screenBackground: Color { semantic.backgroundBase }
    var textPrimary: Color { semantic.textPrimary }
    var textSecondary: Color { semantic.textSecondary }

    // Derived from components for backward compatibility
    var surfaceFillStyle: AnyShapeStyle { components.card.background }
    var cardStroke: Color { components.card.border }
}

extension ThemeDefinition {
    /// Handy accessor to keep wallpaper definition on the theme.
    var wallpaperDefinition: WallpaperDefinition {
        defaultConfiguration.wallpaper.definition
    }
}

extension ThemeWallpaperSelection {
    /// Resolve a wallpaper selection into its definition. Falls back to the selection id.
    var definition: WallpaperDefinition {
        ThemeWallpaperCatalog.definition(for: self) ?? ThemeWallpaperCatalog.fallbackDefinition(id: id)
    }
}
