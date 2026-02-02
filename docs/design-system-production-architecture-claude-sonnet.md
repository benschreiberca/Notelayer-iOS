# Notelayer Design System - Production Architecture

## Philosophy: Theme as Design System Foundation

This document outlines a theme architecture designed to scale into a comprehensive design system. The approach prioritizes:

1. **Semantic token hierarchy** - Abstract design decisions from implementation
2. **Component-driven development** - Themes configure components, not views
3. **Design system scalability** - Easy to add new components, platforms, and brands
4. **Type safety and consistency** - Impossible to use wrong tokens
5. **Documentation-first** - Every decision is documented and discoverable

---

## Part 1: Token Architecture

### Token Hierarchy (4 Levels)

Design systems require clear separation between raw values, semantic meaning, component usage, and context:

```
Level 1: Primitive Tokens (raw values)
    ↓
Level 2: Semantic Tokens (meaning)
    ↓
Level 3: Component Tokens (usage)
    ↓
Level 4: Context Tokens (variants)
```

### Level 1: Primitive Tokens

Raw color, spacing, typography values. Brand-agnostic.

```swift
struct PrimitiveTokens {
    // Color primitives
    struct Colors {
        // Grays
        static let gray50 = Color(hex: "#F9FAFB")
        static let gray100 = Color(hex: "#F3F4F6")
        static let gray200 = Color(hex: "#E5E7EB")
        // ... through gray900
        
        // Brand colors (multiple palettes)
        static let indigo50 = Color(hex: "#EEF2FF")
        static let indigo500 = Color(hex: "#6366F1")
        static let indigo900 = Color(hex: "#312E81")
        
        // Add all color scales: blue, purple, pink, etc.
    }
    
    // Spacing primitives
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // Typography primitives
    struct Typography {
        static let fontFamilyDefault = "SF Pro"
        static let fontFamilyMono = "SF Mono"
        
        static let fontSize10: CGFloat = 10
        static let fontSize12: CGFloat = 12
        static let fontSize14: CGFloat = 14
        static let fontSize16: CGFloat = 16
        static let fontSize20: CGFloat = 20
        static let fontSize24: CGFloat = 24
        static let fontSize32: CGFloat = 32
        
        static let fontWeightRegular: Font.Weight = .regular
        static let fontWeightMedium: Font.Weight = .medium
        static let fontWeightSemibold: Font.Weight = .semibold
        static let fontWeightBold: Font.Weight = .bold
    }
    
    // Radius primitives
    struct Radius {
        static let none: CGFloat = 0
        static let sm: CGFloat = 4
        static let md: CGFloat = 8
        static let lg: CGFloat = 12
        static let xl: CGFloat = 16
        static let full: CGFloat = 9999
    }
    
    // Shadow primitives
    struct Shadows {
        static let sm = (radius: 2.0, x: 0.0, y: 1.0)
        static let md = (radius: 4.0, x: 0.0, y: 2.0)
        static let lg = (radius: 8.0, x: 0.0, y: 4.0)
        static let xl = (radius: 16.0, x: 0.0, y: 8.0)
    }
    
    // Opacity primitives
    struct Opacity {
        static let transparent: Double = 0.0
        static let subtle: Double = 0.05
        static let light: Double = 0.1
        static let medium: Double = 0.3
        static let heavy: Double = 0.6
        static let opaque: Double = 1.0
    }
}
```

**Key principle**: Primitives never change based on theme. They're your raw material.

---

### Level 2: Semantic Tokens

Map primitives to meaning. These DO change per theme and mode.

```swift
struct SemanticTokens {
    let mode: ColorScheme // .light or .dark
    
    // MARK: - Color Semantics
    
    // Brand & Identity
    var brandPrimary: Color
    var brandSecondary: Color
    var brandTertiary: Color
    
    // Interactive States
    var interactivePrimary: Color
    var interactivePrimaryHover: Color
    var interactivePrimaryActive: Color
    var interactivePrimaryDisabled: Color
    
    var interactiveSecondary: Color
    var interactiveSecondaryHover: Color
    var interactiveSecondaryActive: Color
    
    // Backgrounds (hierarchical)
    var backgroundBase: Color          // App background
    var backgroundElevated1: Color     // Cards, dialogs
    var backgroundElevated2: Color     // Nested cards
    var backgroundElevated3: Color     // Popovers, tooltips
    
    var backgroundSubtle: Color        // Subtle backgrounds (hover states)
    var backgroundInverse: Color       // Inverse backgrounds (badges)
    
    // Borders & Dividers
    var borderDefault: Color
    var borderSubtle: Color
    var borderStrong: Color
    var borderFocus: Color
    
    // Text (hierarchical)
    var textPrimary: Color
    var textSecondary: Color
    var textTertiary: Color
    var textDisabled: Color
    var textInverse: Color
    var textOnInteractive: Color       // Text on colored backgrounds
    var textLink: Color
    
    // Status & Feedback
    var statusSuccess: Color
    var statusSuccessSubtle: Color
    var statusWarning: Color
    var statusWarningSubtle: Color
    var statusError: Color
    var statusErrorSubtle: Color
    var statusInfo: Color
    var statusInfoSubtle: Color
    
    // Overlays & Scrim
    var overlayLight: Color            // For overlays on light backgrounds
    var overlayDark: Color             // For overlays on dark backgrounds
    var scrim: Color                   // Modal backdrop
    
    // MARK: - Spacing Semantics
    
    var spacingInline: CGFloat         // Between inline elements
    var spacingStack: CGFloat          // Between stacked elements
    var spacingInset: CGFloat          // Inside containers
    var spacingSection: CGFloat        // Between sections
    var spacingPage: CGFloat           // Page margins
    
    // MARK: - Typography Semantics
    
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
    
    // MARK: - Effect Semantics
    
    var shadowSubtle: ShadowStyle
    var shadowModerate: ShadowStyle
    var shadowStrong: ShadowStyle
    
    var blurSubtle: CGFloat
    var blurModerate: CGFloat
    var blurStrong: CGFloat
}

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
```

**Example semantic token mapping for light mode:**

```swift
extension SemanticTokens {
    static func defaultLight() -> SemanticTokens {
        SemanticTokens(
            mode: .light,
            
            // Brand
            brandPrimary: PrimitiveTokens.Colors.indigo500,
            brandSecondary: PrimitiveTokens.Colors.purple500,
            brandTertiary: PrimitiveTokens.Colors.pink500,
            
            // Interactive
            interactivePrimary: PrimitiveTokens.Colors.indigo500,
            interactivePrimaryHover: PrimitiveTokens.Colors.indigo600,
            interactivePrimaryActive: PrimitiveTokens.Colors.indigo700,
            interactivePrimaryDisabled: PrimitiveTokens.Colors.gray300,
            
            // Backgrounds
            backgroundBase: PrimitiveTokens.Colors.gray50,
            backgroundElevated1: Color.white,
            backgroundElevated2: PrimitiveTokens.Colors.gray50,
            backgroundElevated3: Color.white,
            backgroundSubtle: PrimitiveTokens.Colors.gray100,
            backgroundInverse: PrimitiveTokens.Colors.gray900,
            
            // Borders
            borderDefault: PrimitiveTokens.Colors.gray200,
            borderSubtle: PrimitiveTokens.Colors.gray100,
            borderStrong: PrimitiveTokens.Colors.gray300,
            borderFocus: PrimitiveTokens.Colors.indigo500,
            
            // Text
            textPrimary: PrimitiveTokens.Colors.gray900,
            textSecondary: PrimitiveTokens.Colors.gray600,
            textTertiary: PrimitiveTokens.Colors.gray500,
            textDisabled: PrimitiveTokens.Colors.gray400,
            textInverse: Color.white,
            textOnInteractive: Color.white,
            textLink: PrimitiveTokens.Colors.indigo500,
            
            // Status
            statusSuccess: PrimitiveTokens.Colors.green600,
            statusSuccessSubtle: PrimitiveTokens.Colors.green50,
            statusWarning: PrimitiveTokens.Colors.amber600,
            statusWarningSubtle: PrimitiveTokens.Colors.amber50,
            statusError: PrimitiveTokens.Colors.red600,
            statusErrorSubtle: PrimitiveTokens.Colors.red50,
            statusInfo: PrimitiveTokens.Colors.blue600,
            statusInfoSubtle: PrimitiveTokens.Colors.blue50,
            
            // Overlays
            overlayLight: Color.black.opacity(PrimitiveTokens.Opacity.medium),
            overlayDark: Color.black.opacity(PrimitiveTokens.Opacity.heavy),
            scrim: Color.black.opacity(PrimitiveTokens.Opacity.heavy),
            
            // Spacing
            spacingInline: PrimitiveTokens.Spacing.sm,
            spacingStack: PrimitiveTokens.Spacing.md,
            spacingInset: PrimitiveTokens.Spacing.md,
            spacingSection: PrimitiveTokens.Spacing.xl,
            spacingPage: PrimitiveTokens.Spacing.lg,
            
            // Typography
            typographyDisplayLarge: TypographyStyle(
                font: .system(size: 32, weight: .bold),
                size: 32,
                weight: .bold,
                lineHeight: 40,
                letterSpacing: -0.5
            ),
            // ... define all typography styles
            
            // Effects
            shadowSubtle: ShadowStyle(
                color: Color.black.opacity(0.05),
                radius: PrimitiveTokens.Shadows.sm.radius,
                x: PrimitiveTokens.Shadows.sm.x,
                y: PrimitiveTokens.Shadows.sm.y
            ),
            // ... define all shadow styles
            
            blurSubtle: 4,
            blurModerate: 8,
            blurStrong: 16
        )
    }
    
    static func defaultDark() -> SemanticTokens {
        SemanticTokens(
            mode: .dark,
            
            // Brand (often brighter in dark mode)
            brandPrimary: PrimitiveTokens.Colors.indigo400,
            brandSecondary: PrimitiveTokens.Colors.purple400,
            brandTertiary: PrimitiveTokens.Colors.pink400,
            
            // Interactive (lighter, more vibrant)
            interactivePrimary: PrimitiveTokens.Colors.indigo400,
            interactivePrimaryHover: PrimitiveTokens.Colors.indigo300,
            interactivePrimaryActive: PrimitiveTokens.Colors.indigo200,
            interactivePrimaryDisabled: PrimitiveTokens.Colors.gray600,
            
            // Backgrounds (darker hierarchy)
            backgroundBase: PrimitiveTokens.Colors.gray900,
            backgroundElevated1: PrimitiveTokens.Colors.gray800,
            backgroundElevated2: PrimitiveTokens.Colors.gray700,
            backgroundElevated3: PrimitiveTokens.Colors.gray600,
            backgroundSubtle: PrimitiveTokens.Colors.gray800,
            backgroundInverse: Color.white,
            
            // Borders (lighter to show on dark)
            borderDefault: PrimitiveTokens.Colors.gray700,
            borderSubtle: PrimitiveTokens.Colors.gray800,
            borderStrong: PrimitiveTokens.Colors.gray600,
            borderFocus: PrimitiveTokens.Colors.indigo400,
            
            // Text (inverted hierarchy)
            textPrimary: Color.white,
            textSecondary: PrimitiveTokens.Colors.gray300,
            textTertiary: PrimitiveTokens.Colors.gray400,
            textDisabled: PrimitiveTokens.Colors.gray600,
            textInverse: PrimitiveTokens.Colors.gray900,
            textOnInteractive: PrimitiveTokens.Colors.gray900,
            textLink: PrimitiveTokens.Colors.indigo400,
            
            // Status (adjusted for dark backgrounds)
            statusSuccess: PrimitiveTokens.Colors.green400,
            statusSuccessSubtle: PrimitiveTokens.Colors.green900,
            statusWarning: PrimitiveTokens.Colors.amber400,
            statusWarningSubtle: PrimitiveTokens.Colors.amber900,
            statusError: PrimitiveTokens.Colors.red400,
            statusErrorSubtle: PrimitiveTokens.Colors.red900,
            statusInfo: PrimitiveTokens.Colors.blue400,
            statusInfoSubtle: PrimitiveTokens.Colors.blue900,
            
            // Overlays (lighter scrim on dark)
            overlayLight: Color.white.opacity(PrimitiveTokens.Opacity.light),
            overlayDark: Color.black.opacity(PrimitiveTokens.Opacity.heavy),
            scrim: Color.black.opacity(PrimitiveTokens.Opacity.opaque),
            
            // Spacing (same as light)
            spacingInline: PrimitiveTokens.Spacing.sm,
            spacingStack: PrimitiveTokens.Spacing.md,
            spacingInset: PrimitiveTokens.Spacing.md,
            spacingSection: PrimitiveTokens.Spacing.xl,
            spacingPage: PrimitiveTokens.Spacing.lg,
            
            // Typography (same structure, different rendering)
            typographyDisplayLarge: TypographyStyle(
                font: .system(size: 32, weight: .bold),
                size: 32,
                weight: .bold,
                lineHeight: 40,
                letterSpacing: -0.5
            ),
            // ... same as light mode
            
            // Effects (more pronounced in dark mode)
            shadowSubtle: ShadowStyle(
                color: Color.black.opacity(0.3),
                radius: PrimitiveTokens.Shadows.sm.radius,
                x: PrimitiveTokens.Shadows.sm.x,
                y: PrimitiveTokens.Shadows.sm.y
            ),
            
            blurSubtle: 4,
            blurModerate: 8,
            blurStrong: 16
        )
    }
}
```

---

### Level 3: Component Tokens

Define exactly how each component uses semantic tokens.

```swift
// Component tokens are namespaced by component
struct ComponentTokens {
    let semantic: SemanticTokens
    
    // MARK: - Button Component
    struct Button {
        let semantic: SemanticTokens
        
        // Primary button
        var primaryBackground: Color { semantic.interactivePrimary }
        var primaryBackgroundHover: Color { semantic.interactivePrimaryHover }
        var primaryBackgroundActive: Color { semantic.interactivePrimaryActive }
        var primaryBackgroundDisabled: Color { semantic.interactivePrimaryDisabled }
        var primaryText: Color { semantic.textOnInteractive }
        var primaryBorder: Color { .clear }
        
        var primaryPadding: EdgeInsets {
            EdgeInsets(
                top: semantic.spacingStack,
                leading: semantic.spacingInset,
                bottom: semantic.spacingStack,
                trailing: semantic.spacingInset
            )
        }
        var primaryCornerRadius: CGFloat { PrimitiveTokens.Radius.md }
        var primaryTypography: TypographyStyle { semantic.typographyLabelMedium }
        var primaryShadow: ShadowStyle { semantic.shadowSubtle }
        
        // Secondary button
        var secondaryBackground: Color { .clear }
        var secondaryBackgroundHover: Color { semantic.backgroundSubtle }
        var secondaryBackgroundActive: Color { semantic.backgroundSubtle }
        var secondaryText: Color { semantic.interactivePrimary }
        var secondaryBorder: Color { semantic.borderDefault }
        
        var secondaryPadding: EdgeInsets {
            EdgeInsets(
                top: semantic.spacingStack,
                leading: semantic.spacingInset,
                bottom: semantic.spacingStack,
                trailing: semantic.spacingInset
            )
        }
        var secondaryCornerRadius: CGFloat { PrimitiveTokens.Radius.md }
        var secondaryTypography: TypographyStyle { semantic.typographyLabelMedium }
        
        // Ghost button
        var ghostBackground: Color { .clear }
        var ghostBackgroundHover: Color { semantic.backgroundSubtle }
        var ghostText: Color { semantic.interactivePrimary }
        var ghostBorder: Color { .clear }
    }
    
    // MARK: - Card Component
    struct Card {
        let semantic: SemanticTokens
        
        var background: Color { semantic.backgroundElevated1 }
        var border: Color { semantic.borderSubtle }
        var borderWidth: CGFloat { 1 }
        var cornerRadius: CGFloat { PrimitiveTokens.Radius.lg }
        var padding: EdgeInsets {
            EdgeInsets(
                top: semantic.spacingInset,
                leading: semantic.spacingInset,
                bottom: semantic.spacingInset,
                trailing: semantic.spacingInset
            )
        }
        var shadow: ShadowStyle { semantic.shadowSubtle }
        
        // Nested card (elevated further)
        var nestedBackground: Color { semantic.backgroundElevated2 }
        var nestedBorder: Color { semantic.borderDefault }
    }
    
    // MARK: - Task Item Component
    struct TaskItem {
        let semantic: SemanticTokens
        
        var background: Color { semantic.backgroundElevated1 }
        var backgroundHover: Color { semantic.backgroundSubtle }
        var border: Color { semantic.borderSubtle }
        var borderWidth: CGFloat { 1 }
        var cornerRadius: CGFloat { PrimitiveTokens.Radius.md }
        
        var titleText: Color { semantic.textPrimary }
        var titleTypography: TypographyStyle { semantic.typographyBodyMedium }
        
        var descriptionText: Color { semantic.textSecondary }
        var descriptionTypography: TypographyStyle { semantic.typographyBodySmall }
        
        var metadataText: Color { semantic.textTertiary }
        var metadataTypography: TypographyStyle { semantic.typographyLabelSmall }
        
        var checkboxBorder: Color { semantic.borderDefault }
        var checkboxChecked: Color { semantic.interactivePrimary }
        
        var padding: EdgeInsets {
            EdgeInsets(
                top: semantic.spacingStack,
                leading: semantic.spacingInset,
                bottom: semantic.spacingStack,
                trailing: semantic.spacingInset
            )
        }
        
        var spacing: CGFloat { semantic.spacingStack }
        var shadow: ShadowStyle { semantic.shadowSubtle }
        
        // Completed state
        var completedTitleText: Color { semantic.textTertiary }
        var completedBackground: Color { semantic.backgroundSubtle }
    }
    
    // MARK: - Badge/Chip Component
    struct Badge {
        let semantic: SemanticTokens
        
        var background: Color { semantic.backgroundSubtle }
        var border: Color { semantic.borderDefault }
        var text: Color { semantic.textSecondary }
        var typography: TypographyStyle { semantic.typographyLabelSmall }
        var cornerRadius: CGFloat { PrimitiveTokens.Radius.full }
        var padding: EdgeInsets {
            EdgeInsets(
                top: PrimitiveTokens.Spacing.xs,
                leading: PrimitiveTokens.Spacing.sm,
                bottom: PrimitiveTokens.Spacing.xs,
                trailing: PrimitiveTokens.Spacing.sm
            )
        }
        
        // Accent variant
        var accentBackground: Color { semantic.interactivePrimary.opacity(0.1) }
        var accentBorder: Color { semantic.interactivePrimary.opacity(0.3) }
        var accentText: Color { semantic.interactivePrimary }
        
        // Status variants
        var successBackground: Color { semantic.statusSuccessSubtle }
        var successBorder: Color { semantic.statusSuccess.opacity(0.3) }
        var successText: Color { semantic.statusSuccess }
        
        var warningBackground: Color { semantic.statusWarningSubtle }
        var warningBorder: Color { semantic.statusWarning.opacity(0.3) }
        var warningText: Color { semantic.statusWarning }
        
        var errorBackground: Color { semantic.statusErrorSubtle }
        var errorBorder: Color { semantic.statusError.opacity(0.3) }
        var errorText: Color { semantic.statusError }
    }
    
    // MARK: - Group Header Component
    struct GroupHeader {
        let semantic: SemanticTokens
        
        var background: Color { semantic.backgroundSubtle }
        var titleText: Color { semantic.textPrimary }
        var titleTypography: TypographyStyle { semantic.typographyHeadingSmall }
        var countText: Color { semantic.textSecondary }
        var countTypography: TypographyStyle { semantic.typographyLabelSmall }
        var countBackground: Color { semantic.interactivePrimary.opacity(0.1) }
        var countBorder: Color { semantic.interactivePrimary.opacity(0.3) }
        
        var padding: EdgeInsets {
            EdgeInsets(
                top: semantic.spacingStack,
                leading: semantic.spacingInset,
                bottom: semantic.spacingStack,
                trailing: semantic.spacingInset
            )
        }
        var cornerRadius: CGFloat { PrimitiveTokens.Radius.md }
    }
    
    // Initialize with semantic tokens
    var button: Button { Button(semantic: semantic) }
    var card: Card { Card(semantic: semantic) }
    var taskItem: TaskItem { TaskItem(semantic: semantic) }
    var badge: Badge { Badge(semantic: semantic) }
    var groupHeader: GroupHeader { GroupHeader(semantic: semantic) }
    
    // Add more components as needed...
}
```

---

### Level 4: Context Tokens (Theme Variants)

Themes are just pre-configured semantic token sets with custom wallpapers.

```swift
struct ThemeDefinition {
    let id: String
    let name: String
    let category: ThemeCategory
    
    // Semantic tokens for both modes
    let lightSemanticTokens: SemanticTokens
    let darkSemanticTokens: SemanticTokens
    
    // Wallpaper configuration
    let wallpaper: WallpaperDefinition
    
    // Optional overrides for specific components
    let componentOverrides: ComponentOverrides?
}

struct ComponentOverrides {
    // Override specific component tokens if needed
    var buttonPrimaryBackground: ((SemanticTokens) -> Color)?
    var cardBackground: ((SemanticTokens) -> Color)?
    // etc.
}

enum ThemeCategory {
    case minimal        // Clean, lots of whitespace
    case vibrant        // Bold colors, high contrast
    case soft           // Pastels, low contrast
    case professional   // Corporate, conservative
    case artistic       // Designer gradients, textures
}
```

**Example theme definition:**

```swift
extension ThemeDefinition {
    static let iridescent = ThemeDefinition(
        id: "iridescent",
        name: "Iridescent",
        category: .vibrant,
        
        lightSemanticTokens: SemanticTokens(
            mode: .light,
            
            // Override brand colors for this theme
            brandPrimary: PrimitiveTokens.Colors.indigo500,
            brandSecondary: PrimitiveTokens.Colors.purple500,
            brandTertiary: PrimitiveTokens.Colors.pink400,
            
            // Custom interactive colors
            interactivePrimary: Color(hex: "#6366F1"),
            interactivePrimaryHover: Color(hex: "#5558E3"),
            interactivePrimaryActive: Color(hex: "#4A4BD5"),
            interactivePrimaryDisabled: PrimitiveTokens.Colors.gray300,
            
            // Subtle, light backgrounds
            backgroundBase: Color(hex: "#FAFBFC"),
            backgroundElevated1: Color.white.opacity(0.85),
            backgroundElevated2: Color.white.opacity(0.7),
            backgroundElevated3: Color.white,
            backgroundSubtle: PrimitiveTokens.Colors.gray50,
            backgroundInverse: PrimitiveTokens.Colors.gray900,
            
            // Soft borders
            borderDefault: PrimitiveTokens.Colors.gray200.opacity(0.6),
            borderSubtle: PrimitiveTokens.Colors.gray100.opacity(0.4),
            borderStrong: PrimitiveTokens.Colors.gray300,
            borderFocus: Color(hex: "#6366F1"),
            
            // Standard text
            textPrimary: PrimitiveTokens.Colors.gray900,
            textSecondary: PrimitiveTokens.Colors.gray600,
            textTertiary: PrimitiveTokens.Colors.gray500,
            textDisabled: PrimitiveTokens.Colors.gray400,
            textInverse: Color.white,
            textOnInteractive: Color.white,
            textLink: Color(hex: "#6366F1"),
            
            // ... rest of semantic tokens
        ),
        
        darkSemanticTokens: SemanticTokens(
            mode: .dark,
            
            // Brighter brand in dark mode
            brandPrimary: Color(hex: "#818CF8"),
            brandSecondary: Color(hex: "#A78BFA"),
            brandTertiary: Color(hex: "#F472B6"),
            
            // Vibrant interactive colors
            interactivePrimary: Color(hex: "#818CF8"),
            interactivePrimaryHover: Color(hex: "#9CA3F8"),
            interactivePrimaryActive: Color(hex: "#B4BAF9"),
            interactivePrimaryDisabled: PrimitiveTokens.Colors.gray600,
            
            // Dark, elevated backgrounds
            backgroundBase: Color(hex: "#0A0A0F"),
            backgroundElevated1: Color(hex: "#1A1A24").opacity(0.6),
            backgroundElevated2: Color(hex: "#2A2A3A").opacity(0.4),
            backgroundElevated3: Color(hex: "#3A3A4A"),
            backgroundSubtle: Color(hex: "#1A1A24"),
            backgroundInverse: Color.white,
            
            // Visible borders on dark
            borderDefault: PrimitiveTokens.Colors.gray700.opacity(0.5),
            borderSubtle: PrimitiveTokens.Colors.gray800.opacity(0.3),
            borderStrong: PrimitiveTokens.Colors.gray600,
            borderFocus: Color(hex: "#818CF8"),
            
            // Inverted text
            textPrimary: Color.white,
            textSecondary: PrimitiveTokens.Colors.gray300,
            textTertiary: PrimitiveTokens.Colors.gray400,
            textDisabled: PrimitiveTokens.Colors.gray600,
            textInverse: PrimitiveTokens.Colors.gray900,
            textOnInteractive: PrimitiveTokens.Colors.gray900,
            textLink: Color(hex: "#818CF8"),
            
            // ... rest of semantic tokens
        ),
        
        wallpaper: WallpaperDefinition(
            type: .gradient,
            lightVariant: WallpaperVariant(
                colors: [
                    Color(hex: "#E0E7FF"),
                    Color(hex: "#FDE68A"),
                    Color(hex: "#FCA5A5")
                ],
                gradientType: .angular(center: .center, angle: .degrees(45)),
                patternName: nil,
                patternColors: nil,
                imageName: nil,
                designerConfig: nil
            ),
            darkVariant: WallpaperVariant(
                colors: [
                    Color(hex: "#1E1B4B"),
                    Color(hex: "#7C2D12"),
                    Color(hex: "#7F1D1D")
                ],
                gradientType: .angular(center: .center, angle: .degrees(45)),
                patternName: nil,
                patternColors: nil,
                imageName: nil,
                designerConfig: nil
            )
        ),
        
        componentOverrides: nil
    )
}
```

---

## Part 2: Design System Manager

### Centralized Design System

```swift
@Observable
class DesignSystem {
    // MARK: - State
    
    private(set) var currentTheme: ThemeDefinition
    private(set) var currentMode: ColorScheme
    private(set) var appearancePreference: AppearanceMode
    
    // MARK: - Configuration
    
    var wallpaperIntensity: Double = 0.7 {
        didSet { objectWillChange.send() }
    }
    
    var surfaceBlurIntensity: Double = 0.8 {
        didSet { objectWillChange.send() }
    }
    
    var reducedMotion: Bool = false
    var increasedContrast: Bool = false
    
    // MARK: - Token Access
    
    /// The single source of truth for all design tokens
    var tokens: DesignTokens {
        DesignTokens(
            theme: currentTheme,
            mode: currentMode,
            wallpaperIntensity: wallpaperIntensity,
            surfaceBlurIntensity: surfaceBlurIntensity,
            reducedMotion: reducedMotion,
            increasedContrast: increasedContrast
        )
    }
    
    // MARK: - Initialization
    
    init(
        theme: ThemeDefinition = .iridescent,
        appearancePreference: AppearanceMode = .system
    ) {
        self.currentTheme = theme
        self.appearancePreference = appearancePreference
        self.currentMode = .light // Will be updated by root view
    }
    
    // MARK: - Public API
    
    func setTheme(_ theme: ThemeDefinition) {
        currentTheme = theme
    }
    
    func setAppearancePreference(_ preference: AppearanceMode) {
        appearancePreference = preference
    }
    
    func updateResolvedMode(_ mode: ColorScheme) {
        currentMode = mode
    }
}

enum AppearanceMode: String, Codable, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
}
```

### Design Tokens (Unified Access Point)

```swift
struct DesignTokens {
    // MARK: - Sources
    
    private let theme: ThemeDefinition
    private let mode: ColorScheme
    private let wallpaperIntensity: Double
    private let surfaceBlurIntensity: Double
    private let reducedMotion: Bool
    private let increasedContrast: Bool
    
    // MARK: - Semantic Tokens
    
    var semantic: SemanticTokens {
        mode == .light ? theme.lightSemanticTokens : theme.darkSemanticTokens
    }
    
    // MARK: - Component Tokens
    
    var components: ComponentTokens {
        ComponentTokens(semantic: semantic)
    }
    
    // MARK: - Wallpaper
    
    var wallpaper: WallpaperVariant {
        mode == .light ? theme.wallpaper.lightVariant : theme.wallpaper.darkVariant
    }
    
    // MARK: - Convenience Accessors
    
    // Quick access to common semantic tokens
    var brandPrimary: Color { semantic.brandPrimary }
    var interactivePrimary: Color { semantic.interactivePrimary }
    var backgroundBase: Color { semantic.backgroundBase }
    var backgroundElevated: Color { semantic.backgroundElevated1 }
    var textPrimary: Color { semantic.textPrimary }
    var textSecondary: Color { semantic.textSecondary }
    var borderDefault: Color { semantic.borderDefault }
    
    // Quick access to common component tokens
    var button: ComponentTokens.Button { components.button }
    var card: ComponentTokens.Card { components.card }
    var taskItem: ComponentTokens.TaskItem { components.taskItem }
    var badge: ComponentTokens.Badge { components.badge }
    var groupHeader: ComponentTokens.GroupHeader { components.groupHeader }
    
    // MARK: - Computed Properties (with modifiers applied)
    
    var wallpaperWithIntensity: WallpaperVariant {
        // Apply intensity modifier to wallpaper
        var variant = wallpaper
        // Modify opacity based on wallpaperIntensity
        return variant
    }
    
    var surfaceBlur: CGFloat {
        surfaceBlurIntensity * semantic.blurModerate
    }
    
    // MARK: - Accessibility Adaptations
    
    func adaptedTextColor(_ color: Color) -> Color {
        if increasedContrast {
            // Increase contrast for accessibility
            return mode == .light ? PrimitiveTokens.Colors.gray900 : Color.white
        }
        return color
    }
}
```

---

## Part 3: Component Implementation

### Design System Components

Components should ONLY reference design tokens, never hardcoded values.

```swift
// MARK: - Button Component

struct DSButton: View {
    let title: String
    let style: DSButtonStyle
    let action: () -> Void
    
    @Environment(DesignSystem.self) private var designSystem
    
    var body: some View {
        let tokens = designSystem.tokens.button
        
        Button(action: action) {
            Text(title)
                .font(typography(for: style, tokens: tokens).font)
                .foregroundColor(textColor(for: style, tokens: tokens))
                .padding(padding(for: style, tokens: tokens))
        }
        .background(background(for: style, tokens: tokens))
        .overlay(border(for: style, tokens: tokens))
        .cornerRadius(cornerRadius(for: style, tokens: tokens))
        .shadow(
            color: shadow(for: style, tokens: tokens).color,
            radius: shadow(for: style, tokens: tokens).radius,
            x: shadow(for: style, tokens: tokens).x,
            y: shadow(for: style, tokens: tokens).y
        )
    }
    
    private func background(for style: DSButtonStyle, tokens: ComponentTokens.Button) -> some View {
        Group {
            switch style {
            case .primary:
                tokens.primaryBackground
            case .secondary:
                tokens.secondaryBackground
            case .ghost:
                tokens.ghostBackground
            }
        }
    }
    
    private func textColor(for style: DSButtonStyle, tokens: ComponentTokens.Button) -> Color {
        switch style {
        case .primary: return tokens.primaryText
        case .secondary: return tokens.secondaryText
        case .ghost: return tokens.ghostText
        }
    }
    
    // ... other helper methods
}

enum DSButtonStyle {
    case primary
    case secondary
    case ghost
}

// MARK: - Card Component

struct DSCard<Content: View>: View {
    let nested: Bool
    @ViewBuilder let content: Content
    
    @Environment(DesignSystem.self) private var designSystem
    
    var body: some View {
        let tokens = designSystem.tokens.card
        
        content
            .padding(tokens.padding)
            .background(nested ? tokens.nestedBackground : tokens.background)
            .overlay(
                RoundedRectangle(cornerRadius: tokens.cornerRadius)
                    .stroke(nested ? tokens.nestedBorder : tokens.border, lineWidth: tokens.borderWidth)
            )
            .cornerRadius(tokens.cornerRadius)
            .shadow(
                color: tokens.shadow.color,
                radius: tokens.shadow.radius,
                x: tokens.shadow.x,
                y: tokens.shadow.y
            )
    }
}

// MARK: - Task Item Component

struct DSTaskItem: View {
    let task: Task
    let onToggle: () -> Void
    let onTap: () -> Void
    
    @Environment(DesignSystem.self) private var designSystem
    
    var body: some View {
        let tokens = designSystem.tokens.taskItem
        
        HStack(spacing: tokens.spacing) {
            // Checkbox
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? tokens.checkboxChecked : tokens.checkboxBorder)
            }
            
            VStack(alignment: .leading, spacing: tokens.spacing / 2) {
                // Title
                Text(task.title)
                    .font(tokens.titleTypography.font)
                    .foregroundColor(task.isCompleted ? tokens.completedTitleText : tokens.titleText)
                    .strikethrough(task.isCompleted)
                
                // Description (if present)
                if let description = task.description {
                    Text(description)
                        .font(tokens.descriptionTypography.font)
                        .foregroundColor(tokens.descriptionText)
                }
                
                // Metadata
                HStack(spacing: tokens.spacing / 2) {
                    if let category = task.category {
                        DSBadge(text: category.name, style: .accent)
                    }
                    
                    if let dueDate = task.dueDate {
                        DSBadge(text: formatDate(dueDate), style: .default)
                    }
                }
            }
            
            Spacer()
        }
        .padding(tokens.padding)
        .background(task.isCompleted ? tokens.completedBackground : tokens.background)
        .overlay(
            RoundedRectangle(cornerRadius: tokens.cornerRadius)
                .stroke(tokens.border, lineWidth: tokens.borderWidth)
        )
        .cornerRadius(tokens.cornerRadius)
        .shadow(
            color: tokens.shadow.color,
            radius: tokens.shadow.radius,
            x: tokens.shadow.x,
            y: tokens.shadow.y
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Badge Component

struct DSBadge: View {
    let text: String
    let style: DSBadgeStyle
    
    @Environment(DesignSystem.self) private var designSystem
    
    var body: some View {
        let tokens = designSystem.tokens.badge
        
        Text(text)
            .font(tokens.typography.font)
            .foregroundColor(textColor(for: style, tokens: tokens))
            .padding(tokens.padding)
            .background(background(for: style, tokens: tokens))
            .overlay(
                Capsule()
                    .stroke(border(for: style, tokens: tokens), lineWidth: 1)
            )
            .clipShape(Capsule())
    }
    
    private func background(for style: DSBadgeStyle, tokens: ComponentTokens.Badge) -> Color {
        switch style {
        case .default: return tokens.background
        case .accent: return tokens.accentBackground
        case .success: return tokens.successBackground
        case .warning: return tokens.warningBackground
        case .error: return tokens.errorBackground
        }
    }
    
    private func border(for style: DSBadgeStyle, tokens: ComponentTokens.Badge) -> Color {
        switch style {
        case .default: return tokens.border
        case .accent: return tokens.accentBorder
        case .success: return tokens.successBorder
        case .warning: return tokens.warningBorder
        case .error: return tokens.errorBorder
        }
    }
    
    private func textColor(for style: DSBadgeStyle, tokens: ComponentTokens.Badge) -> Color {
        switch style {
        case .default: return tokens.text
        case .accent: return tokens.accentText
        case .success: return tokens.successText
        case .warning: return tokens.warningText
        case .error: return tokens.errorText
        }
    }
}

enum DSBadgeStyle {
    case `default`
    case accent
    case success
    case warning
    case error
}
```

---

## Part 4: Wallpaper System

### Wallpaper Rendering Engine

```swift
struct WallpaperDefinition: Codable, Hashable {
    let id: String
    let type: WallpaperType
    let lightVariant: WallpaperVariant
    let darkVariant: WallpaperVariant
}

enum WallpaperType: String, Codable {
    case gradient
    case pattern
    case image
    case designer
}

struct WallpaperVariant: Codable, Hashable {
    // Gradient configuration
    let colors: [CodableColor]?
    let gradientType: GradientConfiguration?
    
    // Pattern configuration
    let patternName: String?
    let patternColors: PatternColors?
    
    // Image configuration
    let imageName: String?
    
    // Designer configuration
    let designerConfig: DesignerWallpaperConfig?
}

struct GradientConfiguration: Codable, Hashable {
    let type: GradientType
    let center: UnitPoint
    let angle: Angle?
    let stops: [GradientStop]?
}

enum GradientType: String, Codable {
    case linear
    case radial
    case angular
}

struct PatternColors: Codable, Hashable {
    let foreground: CodableColor
    let background: CodableColor
}

struct DesignerWallpaperConfig: Codable, Hashable {
    let designerType: DesignerType
    let parameters: [String: Double]
}

enum DesignerType: String, Codable {
    case mesh           // Mesh gradients
    case noise          // Perlin noise
    case geometric      // Geometric patterns
    case organic        // Organic shapes
}

// MARK: - Wallpaper Renderer

struct DSWallpaper: View {
    @Environment(DesignSystem.self) private var designSystem
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        let tokens = designSystem.tokens
        let wallpaper = tokens.wallpaperWithIntensity
        let intensity = designSystem.wallpaperIntensity
        
        ZStack {
            // Base background
            tokens.semantic.backgroundBase
                .ignoresSafeArea()
            
            // Wallpaper layer
            Group {
                if let colors = wallpaper.colors?.map(\.color),
                   let gradientConfig = wallpaper.gradientType {
                    renderGradient(colors: colors, config: gradientConfig)
                } else if let patternName = wallpaper.patternName,
                          let patternColors = wallpaper.patternColors {
                    renderPattern(name: patternName, colors: patternColors)
                } else if let imageName = wallpaper.imageName {
                    renderImage(name: imageName)
                } else if let designerConfig = wallpaper.designerConfig {
                    renderDesigner(config: designerConfig)
                }
            }
            .opacity(intensity)
            .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private func renderGradient(colors: [Color], config: GradientConfiguration) -> some View {
        switch config.type {
        case .linear:
            LinearGradient(
                colors: colors,
                startPoint: .top,
                endPoint: .bottom
            )
        case .radial:
            RadialGradient(
                colors: colors,
                center: config.center,
                startRadius: 0,
                endRadius: 500
            )
        case .angular:
            AngularGradient(
                colors: colors,
                center: config.center,
                angle: config.angle ?? .zero
            )
        }
    }
    
    @ViewBuilder
    private func renderPattern(name: String, colors: PatternColors) -> some View {
        // Render pattern from pattern library
        PatternRenderer(
            patternName: name,
            foregroundColor: colors.foreground.color,
            backgroundColor: colors.background.color
        )
    }
    
    @ViewBuilder
    private func renderImage(name: String) -> some View {
        Image(name)
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
    
    @ViewBuilder
    private func renderDesigner(config: DesignerWallpaperConfig) -> some View {
        // Render designer wallpaper
        DesignerWallpaperRenderer(config: config)
    }
}
```

---

## Part 5: Theme Catalog & Presets

### Comprehensive Preset Library

```swift
struct ThemeCatalog {
    static let all: [ThemeDefinition] = [
        // MARK: - Minimal Category
        .pureWhite,
        .carbonBlack,
        .softGray,
        
        // MARK: - Vibrant Category
        .iridescent,
        .neonNights,
        .sunsetBlaze,
        .oceanDepth,
        
        // MARK: - Soft Category
        .lavenderDream,
        .peachSorbet,
        .mintBreeze,
        
        // MARK: - Professional Category
        .corporateBlue,
        .executiveGray,
        .financialGreen,
        
        // MARK: - Artistic Category
        .watercolor,
        .geometricAbstract,
        .meshGradient
    ]
    
    static func themes(for category: ThemeCategory) -> [ThemeDefinition] {
        all.filter { $0.category == category }
    }
}

// MARK: - Example Preset Definitions

extension ThemeDefinition {
    static let pureWhite = ThemeDefinition(
        id: "pure-white",
        name: "Pure White",
        category: .minimal,
        lightSemanticTokens: SemanticTokens(
            mode: .light,
            brandPrimary: PrimitiveTokens.Colors.gray900,
            brandSecondary: PrimitiveTokens.Colors.gray700,
            brandTertiary: PrimitiveTokens.Colors.gray500,
            interactivePrimary: PrimitiveTokens.Colors.gray900,
            interactivePrimaryHover: PrimitiveTokens.Colors.gray800,
            interactivePrimaryActive: PrimitiveTokens.Colors.gray700,
            interactivePrimaryDisabled: PrimitiveTokens.Colors.gray300,
            backgroundBase: Color.white,
            backgroundElevated1: PrimitiveTokens.Colors.gray50,
            backgroundElevated2: Color.white,
            backgroundElevated3: PrimitiveTokens.Colors.gray50,
            backgroundSubtle: PrimitiveTokens.Colors.gray100,
            backgroundInverse: PrimitiveTokens.Colors.gray900,
            // ... complete all semantic tokens
        ),
        darkSemanticTokens: SemanticTokens.defaultDark(),
        wallpaper: WallpaperDefinition(
            id: "pure-white-wallpaper",
            type: .gradient,
            lightVariant: WallpaperVariant(
                colors: [.white, .white].map { CodableColor($0) },
                gradientType: GradientConfiguration(type: .linear, center: .center, angle: nil, stops: nil),
                patternName: nil,
                patternColors: nil,
                imageName: nil,
                designerConfig: nil
            ),
            darkVariant: WallpaperVariant(
                colors: [Color(hex: "#0A0A0F"), Color(hex: "#1A1A1F")].map { CodableColor($0) },
                gradientType: GradientConfiguration(type: .linear, center: .center, angle: nil, stops: nil),
                patternName: nil,
                patternColors: nil,
                imageName: nil,
                designerConfig: nil
            )
        ),
        componentOverrides: nil
    )
    
    static let neonNights = ThemeDefinition(
        id: "neon-nights",
        name: "Neon Nights",
        category: .vibrant,
        lightSemanticTokens: SemanticTokens(
            mode: .light,
            brandPrimary: Color(hex: "#FF00FF"),
            brandSecondary: Color(hex: "#00FFFF"),
            brandTertiary: Color(hex: "#FFFF00"),
            interactivePrimary: Color(hex: "#FF00FF"),
            interactivePrimaryHover: Color(hex: "#E600E6"),
            interactivePrimaryActive: Color(hex: "#CC00CC"),
            interactivePrimaryDisabled: PrimitiveTokens.Colors.gray300,
            backgroundBase: Color.white,
            backgroundElevated1: Color(hex: "#FAFAFA"),
            backgroundElevated2: Color.white,
            backgroundElevated3: Color(hex: "#FAFAFA"),
            backgroundSubtle: Color(hex: "#F5F5F5"),
            backgroundInverse: Color(hex: "#0A0A0F"),
            // ... complete all semantic tokens
        ),
        darkSemanticTokens: SemanticTokens(
            mode: .dark,
            brandPrimary: Color(hex: "#FF66FF"),
            brandSecondary: Color(hex: "#66FFFF"),
            brandTertiary: Color(hex: "#FFFF66"),
            interactivePrimary: Color(hex: "#FF66FF"),
            interactivePrimaryHover: Color(hex: "#FF99FF"),
            interactivePrimaryActive: Color(hex: "#FFCCFF"),
            interactivePrimaryDisabled: PrimitiveTokens.Colors.gray600,
            backgroundBase: Color(hex: "#0A0A0F"),
            backgroundElevated1: Color(hex: "#1A1A1F"),
            backgroundElevated2: Color(hex: "#2A2A2F"),
            backgroundElevated3: Color(hex: "#3A3A3F"),
            backgroundSubtle: Color(hex: "#1A1A1F"),
            backgroundInverse: Color.white,
            // ... complete all semantic tokens
        ),
        wallpaper: WallpaperDefinition(
            id: "neon-nights-wallpaper",
            type: .gradient,
            lightVariant: WallpaperVariant(
                colors: [
                    Color(hex: "#FFE6FF"),
                    Color(hex: "#E6F7FF"),
                    Color(hex: "#FFFFE6")
                ].map { CodableColor($0) },
                gradientType: GradientConfiguration(
                    type: .angular,
                    center: .center,
                    angle: .degrees(45),
                    stops: nil
                ),
                patternName: nil,
                patternColors: nil,
                imageName: nil,
                designerConfig: nil
            ),
            darkVariant: WallpaperVariant(
                colors: [
                    Color(hex: "#330033"),
                    Color(hex: "#003333"),
                    Color(hex: "#333300")
                ].map { CodableColor($0) },
                gradientType: GradientConfiguration(
                    type: .angular,
                    center: .center,
                    angle: .degrees(45),
                    stops: nil
                ),
                patternName: nil,
                patternColors: nil,
                imageName: nil,
                designerConfig: nil
            )
        ),
        componentOverrides: ComponentOverrides(
            buttonPrimaryBackground: { semantic in
                LinearGradient(
                    colors: [semantic.brandPrimary, semantic.brandSecondary],
                    startPoint: .leading,
                    endPoint: .trailing
                ).any
            },
            cardBackground: { semantic in
                semantic.backgroundElevated1.opacity(0.6)
            }
        )
    )
}
```

---

## Part 6: Customization Interface

### Theme Selection & Customization

```swift
struct ThemeSelectionView: View {
    @Environment(DesignSystem.self) private var designSystem
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCategory: ThemeCategory = .vibrant
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: designSystem.tokens.semantic.spacingSectionappearanceSection
                
                // Category filter
                categoryPicker
                
                // Theme grid
                themeGrid
            }
            .navigationTitle("Choose Theme")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink("Customize") {
                        ThemeCustomizationView()
                    }
                }
            }
        }
    }
    
    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Appearance")
                .font(designSystem.tokens.semantic.typographyHeadingSmall.font)
                .foregroundColor(designSystem.tokens.textPrimary)
            
            Picker("", selection: $designSystem.appearancePreference) {
                Text("Light").tag(AppearanceMode.light)
                Text("Dark").tag(AppearanceMode.dark)
                Text("System").tag(AppearanceMode.system)
            }
            .pickerStyle(.segmented)
            .tint(designSystem.tokens.interactivePrimary)
        }
        .padding(designSystem.tokens.semantic.spacingInset)
    }
    
    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ThemeCategory.allCases, id: \.self) { category in
                    categoryChip(category)
                }
            }
            .padding(.horizontal, designSystem.tokens.semantic.spacingInset)
        }
    }
    
    private func categoryChip(_ category: ThemeCategory) -> some View {
        Button {
            selectedCategory = category
        } label: {
            Text(category.displayName)
                .font(designSystem.tokens.semantic.typographyLabelMedium.font)
                .foregroundColor(
                    selectedCategory == category
                        ? designSystem.tokens.semantic.textOnInteractive
                        : designSystem.tokens.textPrimary
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    selectedCategory == category
                        ? designSystem.tokens.interactivePrimary
                        : designSystem.tokens.semantic.backgroundSubtle
                )
                .cornerRadius(PrimitiveTokens.Radius.full)
        }
    }
    
    private var themeGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ],
            spacing: 16
        ) {
            ForEach(ThemeCatalog.themes(for: selectedCategory), id: \.id) { theme in
                themePreviewTile(theme)
            }
        }
        .padding(.horizontal, designSystem.tokens.semantic.spacingInset)
    }
    
    private func themePreviewTile(_ theme: ThemeDefinition) -> some View {
        let isSelected = designSystem.currentTheme.id == theme.id
        
        return Button {
            designSystem.setTheme(theme)
        } label: {
            VStack(spacing: 8) {
                // Preview
                ZStack {
                    // Wallpaper background
                    themeWallpaperPreview(theme)
                    
                    // Sample UI elements
                    VStack(spacing: 4) {
                        // Sample card
                        RoundedRectangle(cornerRadius: 8)
                            .fill(previewTokens(theme).card.background.opacity(0.8))
                            .frame(height: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(previewTokens(theme).card.border, lineWidth: 1)
                            )
                        
                        // Sample button
                        RoundedRectangle(cornerRadius: 6)
                            .fill(previewTokens(theme).button.primaryBackground)
                            .frame(height: 24)
                    }
                    .padding(8)
                }
                .aspectRatio(1.2, contentMode: .fit)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isSelected ? designSystem.tokens.interactivePrimary : Color.clear,
                            lineWidth: 3
                        )
                )
                
                // Name
                Text(theme.name)
                    .font(designSystem.tokens.semantic.typographyLabelSmall.font)
                    .foregroundColor(designSystem.tokens.textPrimary)
            }
        }
    }
    
    @ViewBuilder
    private func themeWallpaperPreview(_ theme: ThemeDefinition) -> some View {
        let tokens = previewTokens(theme)
        let wallpaper = tokens.wallpaper
        
        if let colors = wallpaper.colors?.map(\.color),
           let gradientConfig = wallpaper.gradientType {
            // Render gradient preview
            switch gradientConfig.type {
            case .linear:
                LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
            case .radial:
                RadialGradient(colors: colors, center: .center, startRadius: 0, endRadius: 100)
            case .angular:
                AngularGradient(colors: colors, center: .center)
            }
        } else {
            tokens.semantic.backgroundBase
        }
    }
    
    private func previewTokens(_ theme: ThemeDefinition) -> DesignTokens {
        DesignTokens(
            theme: theme,
            mode: designSystem.currentMode,
            wallpaperIntensity: 0.7,
            surfaceBlurIntensity: 0.8,
            reducedMotion: false,
            increasedContrast: false
        )
    }
}

// MARK: - Theme Customization

struct ThemeCustomizationView: View {
    @Environment(DesignSystem.self) private var designSystem
    
    var body: some View {
        Form {
            // Wallpaper customization
            wallpaperSection
            
            // Intensity controls
            intensitySection
            
            // Surface styling
            surfaceSection
            
            // Advanced
            advancedSection
        }
        .navigationTitle("Customize Theme")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var wallpaperSection: some View {
        Section {
            NavigationLink("Change Wallpaper") {
                WallpaperSelectionView()
            }
        } header: {
            Text("Wallpaper")
        }
    }
    
    private var intensitySection: some View {
        Section {
            VStack(alignment: .leading, spacing: 16) {
                // Background intensity
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Background Strength")
                        Spacer()
                        Text("\(Int(designSystem.wallpaperIntensity * 100))%")
                            .foregroundColor(designSystem.tokens.textSecondary)
                    }
                    .font(designSystem.tokens.semantic.typographyBodySmall.font)
                    
                    Slider(value: $designSystem.wallpaperIntensity, in: 0.0...1.0)
                        .tint(designSystem.tokens.interactivePrimary)
                }
                
                // Surface blur
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Surface Blur")
                        Spacer()
                        Text("\(Int(designSystem.surfaceBlurIntensity * 100))%")
                            .foregroundColor(designSystem.tokens.textSecondary)
                    }
                    .font(designSystem.tokens.semantic.typographyBodySmall.font)
                    
                    Slider(value: $designSystem.surfaceBlurIntensity, in: 0.0...1.0)
                        .tint(designSystem.tokens.interactivePrimary)
                }
            }
        } header: {
            Text("Intensity")
        } footer: {
            Text("Adjust how prominent the wallpaper and surface effects appear.")
        }
    }
    
    private var surfaceSection: some View {
        Section {
            // Surface style picker would go here
            Text("Surface styling options")
        } header: {
            Text("Surface Style")
        }
    }
    
    private var advancedSection: some View {
        Section {
            Toggle("Reduced Motion", isOn: $designSystem.reducedMotion)
            Toggle("Increased Contrast", isOn: $designSystem.increasedContrast)
        } header: {
            Text("Accessibility")
        }
    }
}
```

---

## Part 7: Documentation & Export

### Design System Documentation

Every design system should include comprehensive documentation. Here's the structure:

```
/DesignSystem
  /Documentation
    - TokenReference.md          # All tokens with examples
    - ComponentLibrary.md        # All components with usage
    - ThemeGuide.md             # How to create custom themes
    - AccessibilityGuide.md     # Accessibility requirements
    - MigrationGuide.md         # Upgrading between versions
    
  /Exports
    - tokens.json               # Exportable token definitions
    - figma-tokens.json         # Figma compatible
    - css-variables.css         # CSS variable export
    
  /Examples
    - CustomThemeExample.swift  # How to create themes
    - ComponentExample.swift    # How to create components
```

### Token Export Format

```json
{
  "primitive": {
    "colors": {
      "gray": {
        "50": "#F9FAFB",
        "100": "#F3F4F6",
        ...
      },
      "indigo": {
        "50": "#EEF2FF",
        "500": "#6366F1",
        ...
      }
    },
    "spacing": {
      "xs": 4,
      "sm": 8,
      "md": 16,
      ...
    }
  },
  "semantic": {
    "light": {
      "brandPrimary": "$primitive.colors.indigo.500",
      "interactivePrimary": "$primitive.colors.indigo.500",
      ...
    },
    "dark": {
      "brandPrimary": "$primitive.colors.indigo.400",
      "interactivePrimary": "$primitive.colors.indigo.400",
      ...
    }
  },
  "component": {
    "button": {
      "primary": {
        "background": "$semantic.interactivePrimary",
        "text": "$semantic.textOnInteractive",
        ...
      }
    }
  }
}
```

---

## Part 8: Testing & Validation

### Design System Tests

```swift
// MARK: - Token Consistency Tests

class DesignSystemTests: XCTestCase {
    func testAllComponentsUseSemantictokens() {
        // Verify no components use PrimitiveTokens directly
        // Verify all components access tokens through DesignSystem
    }
    
    func testLightDarkModeContrast() {
        // Verify all text/background combinations meet WCAG AA
        let lightTokens = SemanticTokens.defaultLight()
        let darkTokens = SemanticTokens.defaultDark()
        
        XCTAssertTrue(hasMinimumContrast(
            text: lightTokens.textPrimary,
            background: lightTokens.backgroundBase,
            ratio: 4.5
        ))
        
        XCTAssertTrue(hasMinimumContrast(
            text: darkTokens.textPrimary,
            background: darkTokens.backgroundBase,
            ratio: 4.5
        ))
    }
    
    func testAllThemesHaveBothModes() {
        for theme in ThemeCatalog.all {
            XCTAssertNotNil(theme.lightSemanticTokens)
            XCTAssertNotNil(theme.darkSemanticTokens)
            XCTAssertNotNil(theme.wallpaper.lightVariant)
            XCTAssertNotNil(theme.wallpaper.darkVariant)
        }
    }
    
    func testTokenResolution() {
        let designSystem = DesignSystem(theme: .iridescent)
        
        // Light mode
        designSystem.updateResolvedMode(.light)
        XCTAssertEqual(
            designSystem.tokens.semantic.mode,
            .light
        )
        
        // Dark mode
        designSystem.updateResolvedMode(.dark)
        XCTAssertEqual(
            designSystem.tokens.semantic.mode,
            .dark
        )
    }
}
```

---

## Implementation Checklist

### Phase 1: Foundation (Week 1)
- [ ] Create `PrimitiveTokens` with all base values
- [ ] Create `SemanticTokens` structure
- [ ] Define `SemanticTokens.defaultLight()` and `SemanticTokens.defaultDark()`
- [ ] Create `DesignSystem` manager
- [ ] Create `DesignTokens` unified access

### Phase 2: Components (Week 2)
- [ ] Define `ComponentTokens` structure
- [ ] Implement `ComponentTokens.Button`
- [ ] Implement `ComponentTokens.Card`
- [ ] Implement `ComponentTokens.TaskItem`
- [ ] Implement `ComponentTokens.Badge`
- [ ] Implement `ComponentTokens.GroupHeader`
- [ ] Create `DSButton` component
- [ ] Create `DSCard` component
- [ ] Create `DSTaskItem` component
- [ ] Create `DSBadge` component

### Phase 3: Themes (Week 3)
- [ ] Define `ThemeDefinition` structure
- [ ] Create wallpaper system (`WallpaperDefinition`, `WallpaperVariant`)
- [ ] Implement `DSWallpaper` renderer
- [ ] Create 3-5 base themes with full light/dark definitions
- [ ] Test all themes in both modes

### Phase 4: Customization (Week 4)
- [ ] Implement `ThemeSelectionView`
- [ ] Implement `ThemeCustomizationView`
- [ ] Implement `WallpaperSelectionView`
- [ ] Add intensity controls
- [ ] Add appearance mode picker
- [ ] Test customization persistence

### Phase 5: Migration & Polish (Week 5)
- [ ] Create migration logic for existing users
- [ ] Add debug overlay
- [ ] Write documentation
- [ ] Export token definitions
- [ ] Write tests
- [ ] Polish UI transitions

---

## Key Principles Summary

1. **Four-level token hierarchy**: Primitive → Semantic → Component → Context
2. **Explicit light/dark definitions**: No runtime adaptation, explicit palettes
3. **Component isolation**: Components only access tokens, never raw values
4. **Type safety**: Impossible to use wrong tokens
5. **Scalability**: Easy to add new themes, components, platforms
6. **Documentation-first**: Every decision documented
7. **Accessibility-built-in**: Contrast, reduced motion, increased contrast
8. **Exportable**: Can export to JSON, CSS, Figma

This architecture scales from a simple app to a multi-platform design system used across web, iOS, Android, and beyond.
