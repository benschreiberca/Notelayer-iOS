import SwiftUI

struct AppearanceView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var theme: ThemeManager
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Theme Mode") {
                    Picker("Theme", selection: $theme.mode) {
                        ForEach(ThemeMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue.capitalized).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Palettes") {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10)
                    ], spacing: 10) {
                        ForEach(ThemePreset.allCases) { preset in
                            PaletteTile(
                                preset: preset,
                                isSelected: theme.preset == preset,
                                onSelect: { theme.preset = preset }
                            )
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Colour Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundStyle(theme.tokens.accent)
                }
            }
        }
    }
}

private struct PaletteTile: View {
    let preset: ThemePreset
    let isSelected: Bool
    let onSelect: () -> Void
    @EnvironmentObject private var theme: ThemeManager

    var body: some View {
        let tokens = ThemeTokens(preset: preset)
        
        // Force the tile to use the color scheme selected in the picker
        let tileColorScheme: ColorScheme = {
            switch theme.mode {
            case .light: return .light
            case .dark: return .dark
            case .system:
                // Fallback to system color scheme if "System" is selected
                return UIScreen.main.traitCollection.userInterfaceStyle == .dark ? .dark : .light
            }
        }()
        
        let actualBg = tileColorScheme == .dark ? tokens.darkBackground : tokens.lightBackground
        let isLightPreset = isLightColor(actualBg)
        
        Button(action: onSelect) {
            ZStack {
                ZStack {
                    tokens.screenBackground
                    ThemeBackground(preset: preset)
                }
                .environment(\.colorScheme, tileColorScheme) // Force background to follow picker
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.black.opacity(0.04))
                )
                .frame(height: 88)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Circle()
                            .fill(tokens.accent)
                            .frame(width: 10, height: 10)
                        Spacer()
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(tokens.accent)
                        }
                    }
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(tokens.cardFill)
                        .environment(\.colorScheme, tileColorScheme) // Force card to follow picker
                        .frame(height: 18)
                    Spacer()
                    Text(preset.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(isLightPreset ? .black : .white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(10)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? tokens.accent.opacity(0.8) : Color(.separator).opacity(0.18), lineWidth: isSelected ? 2 : 0.5)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func isLightColor(_ color: Color) -> Bool {
        let uiColor = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        // Try to get RGBA components
        if uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) {
            let luminance = 0.299 * r + 0.587 * g + 0.114 * b
            return luminance > 0.6 // Slightly higher threshold for "light"
        }
        
        // Fallback for other color spaces
        var white: CGFloat = 0
        if uiColor.getWhite(&white, alpha: &a) {
            return white > 0.6
        }
        
        return true // Default to light if we can't determine
    }
}
