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
            .navigationTitle("Appearance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private struct PaletteTile: View {
    let preset: ThemePreset
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            ZStack {
                ZStack {
                    ThemeTokens(preset: preset).screenBackground
                    ThemeBackground(preset: preset)
                }
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.black.opacity(0.04))
                )
                .frame(height: 88)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Circle()
                            .fill(ThemeTokens(preset: preset).accent)
                            .frame(width: 10, height: 10)
                        Spacer()
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(ThemeTokens(preset: preset).accent)
                        }
                    }
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(ThemeTokens(preset: preset).cardFill)
                        .frame(height: 18)
                    Spacer()
                    Text(preset.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(10)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? ThemeTokens(preset: preset).accent.opacity(0.8) : Color(.separator).opacity(0.18), lineWidth: isSelected ? 2 : 0.5)
            )
        }
        .buttonStyle(.plain)
    }
}
