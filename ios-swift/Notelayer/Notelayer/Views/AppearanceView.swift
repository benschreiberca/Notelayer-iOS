import SwiftUI
import PhotosUI
import UIKit

struct AppearanceView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var theme: ThemeManager

    @State private var showingCustomize = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    modePicker
                    let presets = filteredPresets
                    presetRow(title: "Traditional", presets: presets.filter { $0.category == .traditional })
                    presetRow(title: "Patterns", presets: presets.filter { $0.category == .pattern })
                    Button("Fully customize Notelayer") {
                        showingCustomize = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(theme.tokens.accent)
                }
                .padding(16)
            }
            .navigationTitle("Themes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showingCustomize) {
                CustomizeThemeView()
                    .environmentObject(theme)
                    .presentationDetents([.fraction(0.85)])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private var modePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Appearance Mode")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Picker("Theme", selection: modeBinding) {
                ForEach(ThemeMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue.capitalized).tag(mode)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var modeBinding: Binding<ThemeMode> {
        Binding(
            get: { theme.mode },
            set: { theme.updateMode($0) }
        )
    }

    private func presetRow(title: String, presets: [ThemeDefinition]) -> some View {
        let selectedId = theme.selectedPresetId ?? ThemeCatalog.defaultTheme.id
        return VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(presets) { preset in
                        PresetTile(
                            preset: preset,
                            isSelected: selectedId == preset.id,
                            onSelect: { theme.applyPreset(preset) }
                        )
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var filteredPresets: [ThemeDefinition] {
        ThemeCatalog.themes(for: theme.mode)
    }
}

private struct PresetTile: View {
    let preset: ThemeDefinition
    let isSelected: Bool
    let onSelect: () -> Void
    @EnvironmentObject private var theme: ThemeManager
    @Environment(\.colorScheme) private var systemScheme

    var body: some View {
        Button(action: onSelect) {
            ZStack(alignment: .bottomLeading) {
                ThemeBackground(
                    configuration: previewConfiguration,
                    tokens: previewTokens,
                    ignoresSafeArea: false
                )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Circle()
                            .fill(previewTokens.accent)
                            .frame(width: 10, height: 10)
                        Spacer()
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(previewTokens.accent)
                        }
                    }
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(previewTokens.components.card.background)
                        .frame(height: 18)
                    Text(preset.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.black.opacity(0.15))
                )
                .padding(10)
            }
            .frame(height: 120)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? previewTokens.accent.opacity(0.8) : Color(.separator).opacity(0.18), lineWidth: isSelected ? 2 : 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    private var previewConfiguration: ThemeConfiguration {
        preset.defaultConfiguration
    }

    private var previewTokens: DesignTokens {
        DesignTokens(
            theme: preset,
            configuration: previewConfiguration,
            resolvedMode: resolvedPreviewScheme
        )
    }

    private var resolvedPreviewScheme: ColorScheme {
        switch theme.mode {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return systemScheme
        }
    }
}

private struct CustomizeThemeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var theme: ThemeManager

    // Snapshot of the entry state to drive the "unsaved" indicator and Save button state.
    @State private var baseConfiguration: ThemeConfiguration = ThemeCatalog.defaultTheme.defaultConfiguration
    @State private var baseMode: ThemeMode = .system
    @State private var baseName: String = ""

    @State private var showingSavePrompt = false
    @State private var saveName = ""
    @State private var showingAllWallpapers = false

    @State private var imagePickerItem: PhotosPickerItem? = nil
    @State private var patternPickerItem: PhotosPickerItem? = nil

    @State private var renameTarget: SavedTheme? = nil
    @State private var renameText: String = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(statusLabel)
                            .font(.subheadline.weight(.semibold))
                        Text(baseSubtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                Section("Appearance Mode") {
                    Picker("Theme", selection: modeBinding) {
                        ForEach(ThemeMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue.capitalized).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Wallpaper") {
                    WallpaperCategoryRow(
                        title: "Gradients",
                        items: ThemeWallpaperCatalog.gradients.map { .gradient($0) },
                        selection: theme.configuration.wallpaper,
                        onSelect: updateWallpaper
                    )
                    WallpaperCategoryRow(
                        title: "Patterns",
                        items: ThemeWallpaperCatalog.patterns.map { .pattern($0) } + ThemeWallpaperCatalog.designers.map { .designer($0) },
                        selection: theme.configuration.wallpaper,
                        onSelect: updateWallpaper
                    )

                    WallpaperCategoryRow(
                        title: "Images",
                        items: theme.userWallpapers.map { .image($0) },
                        selection: theme.configuration.wallpaper,
                        onSelect: updateWallpaper
                    )

                    Button("More Wallpapers") {
                        showingAllWallpapers = true
                    }

                    PhotosPicker(selection: $imagePickerItem, matching: .images) {
                        Label("Upload Image", systemImage: "photo")
                    }

                    PhotosPicker(selection: $patternPickerItem, matching: .images) {
                        Label("Upload Pattern", systemImage: "square.grid.3x3.fill")
                    }
                }

                Section("Accent") {
                    AccentGrid(
                        accents: ThemeAccentCatalog.accents,
                        selectedAccent: theme.configuration.accent,
                        onSelect: updateAccent
                    )
                }

                Section("Sections") {
                    AccentGrid(
                        accents: ThemeAccentCatalog.accents,
                        selectedAccent: theme.configuration.sectionTint,
                        onSelect: updateSectionTint
                    )
                }

                Section("Surfaces") {
                    SurfaceSlider(style: theme.configuration.surfaceStyle) { style in
                        updateSurfaceStyle(style)
                    }
                }

                Section("Intensity") {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Background Strength")
                                Spacer()
                                Text("\(Int(theme.configuration.intensity * 100))%")
                                    .foregroundStyle(.secondary)
                            }
                            .font(.caption)
                            Slider(value: intensityBinding, in: 0...1)
                                .tint(theme.tokens.accent)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Card Transparency")
                                Spacer()
                                Text("\(Int(theme.configuration.surfaceOpacity * 100))%")
                                    .foregroundStyle(.secondary)
                            }
                            .font(.caption)
                            Slider(value: surfaceOpacityBinding, in: 0...1)
                                .tint(theme.tokens.accent)
                        }

                        Text("Controls wallpaper strength and card transparency independently.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Saved Themes") {
                    if theme.savedThemes.isEmpty {
                        Text("No saved themes yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(theme.savedThemes) { saved in
                            Button {
                                applySavedTheme(saved)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(saved.name)
                                            .font(.subheadline.weight(.semibold))
                                        Text("Updated \(relativeDate(saved.updatedAt))")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    if theme.selectedCustomThemeId == saved.id {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(theme.tokens.accent)
                                    }
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    theme.deleteSavedTheme(id: saved.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }

                                Button {
                                    renameTarget = saved
                                    renameText = saved.name
                                } label: {
                                    Label("Rename", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .navigationTitle("Customize Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveName = defaultSaveName
                        showingSavePrompt = true
                    }
                    .disabled(!isDirty)
                }
            }
            .onAppear(perform: snapshotBaseState)
            .onChange(of: imagePickerItem) { newValue in
                handlePickedImage(newValue, mode: .fill)
                imagePickerItem = nil
            }
            .onChange(of: patternPickerItem) { newValue in
                handlePickedImage(newValue, mode: .tile)
                patternPickerItem = nil
            }
            .sheet(isPresented: $showingAllWallpapers) {
                AllWallpapersView(selection: theme.configuration.wallpaper, onSelect: updateWallpaper)
                    .environmentObject(theme)
            }
            .alert("Save Theme", isPresented: $showingSavePrompt) {
                TextField("Theme name", text: $saveName)
                Button("Cancel", role: .cancel) {}
                Button("Save") {
                    theme.saveTheme(named: saveName)
                    snapshotBaseState()
                }
            } message: {
                Text("Save your current theme for one-tap reuse.")
            }
            .alert("Rename Theme", isPresented: renameBinding) {
                TextField("Theme name", text: $renameText)
                Button("Cancel", role: .cancel) {}
                Button("Rename") {
                    if let target = renameTarget {
                        theme.renameSavedTheme(id: target.id, to: renameText)
                        if theme.selectedCustomThemeId == target.id {
                            baseName = renameText
                        }
                    }
                }
            } message: {
                Text("Rename your saved theme.")
            }
        }
    }

    private var statusLabel: String {
        isDirty ? "Custom Theme • Unsaved" : "Based on: \(baseName)"
    }

    private var baseSubtitle: String {
        isDirty ? "Save to keep these changes." : "Adjust any control to create a custom theme."
    }

    private var defaultSaveName: String {
        baseName.isEmpty ? "Custom Theme" : "\(baseName) Custom"
    }

    private var isDirty: Bool {
        baseConfiguration != theme.configuration || baseMode != theme.mode
    }

    private var intensityBinding: Binding<Double> {
        Binding(
            get: { theme.configuration.intensity },
            set: { newValue in
                updateConfiguration { $0.intensity = ThemeConfiguration.clampedIntensity(newValue) }
            }
        )
    }

    private var surfaceOpacityBinding: Binding<Double> {
        Binding(
            get: { theme.configuration.surfaceOpacity },
            set: { newValue in
                updateConfiguration { $0.surfaceOpacity = ThemeConfiguration.clampedOpacity(newValue) }
            }
        )
    }

    private var modeBinding: Binding<ThemeMode> {
        Binding(
            get: { theme.mode },
            set: { theme.updateMode($0) }
        )
    }

    private var renameBinding: Binding<Bool> {
        Binding(
            get: { renameTarget != nil },
            set: { if !$0 { renameTarget = nil } }
        )
    }

    private func snapshotBaseState() {
        baseConfiguration = theme.configuration
        baseMode = theme.mode
        baseName = theme.activeTheme?.name ?? theme.activeSavedTheme?.name ?? "Custom"
    }

    private func updateConfiguration(_ update: (inout ThemeConfiguration) -> Void) {
        var updated = theme.configuration
        update(&updated)
        theme.updateConfiguration(updated)
    }

    private func updateWallpaper(_ selection: ThemeWallpaperSelection) {
        updateConfiguration { $0.wallpaper = selection }
    }

    private func updateAccent(_ accent: ThemeAccent) {
        updateConfiguration { $0.accent = accent }
    }

    private func updateSectionTint(_ accent: ThemeAccent) {
        updateConfiguration { $0.sectionTint = accent }
    }

    private func updateSurfaceStyle(_ style: ThemeSurfaceStyle) {
        updateConfiguration { $0.surfaceStyle = style }
    }

    private func applySavedTheme(_ saved: SavedTheme) {
        theme.applySavedTheme(saved)
        baseConfiguration = saved.configuration
        baseMode = saved.mode
        baseName = saved.name
    }

    private func handlePickedImage(_ item: PhotosPickerItem?, mode: ImageWallpaperMode) {
        guard let item else { return }
        _Concurrency.Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data),
               let pngData = image.pngData() {
                let name = mode == .tile ? "Pattern" : "Photo"
                // Persist to disk and immediately select the new wallpaper.
                if let wallpaper = theme.addUserWallpaper(name: name, data: pngData, mode: mode) {
                    updateWallpaper(
                        ThemeWallpaperSelection(
                            kind: .image,
                            id: wallpaper.id,
                            imageFilename: wallpaper.filename,
                            imageMode: wallpaper.mode
                        )
                    )
                }
            }
        }
    }

    private func relativeDate(_ timestamp: TimeInterval) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: Date(timeIntervalSince1970: timestamp), relativeTo: Date())
    }
}

private enum WallpaperOption: Identifiable {
    case gradient(ThemeGradientDefinition)
    case pattern(ThemePatternDefinition)
    case designer(ThemeDesignerDefinition)
    case image(UserWallpaper)

    var id: String {
        switch self {
        case .gradient(let item): return item.id
        case .pattern(let item): return item.id
        case .designer(let item): return item.id
        case .image(let item): return item.id
        }
    }

    var name: String {
        switch self {
        case .gradient(let item): return item.name
        case .pattern(let item): return item.name
        case .designer(let item): return item.name
        case .image(let item): return item.name
        }
    }

    var selection: ThemeWallpaperSelection {
        switch self {
        case .gradient(let item):
            return ThemeWallpaperSelection(kind: .gradient, id: item.id, imageFilename: nil, imageMode: nil)
        case .pattern(let item):
            return ThemeWallpaperSelection(kind: .pattern, id: item.id, imageFilename: nil, imageMode: nil)
        case .designer(let item):
            return ThemeWallpaperSelection(kind: .designer, id: item.id, imageFilename: nil, imageMode: nil)
        case .image(let item):
            return ThemeWallpaperSelection(kind: .image, id: item.id, imageFilename: item.filename, imageMode: item.mode)
        }
    }
}

private struct WallpaperCategoryRow: View {
    let title: String
    let items: [WallpaperOption]
    let selection: ThemeWallpaperSelection
    let onSelect: (ThemeWallpaperSelection) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.top, 4)
                .padding(.bottom, 2)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    if items.isEmpty {
                        WallpaperPlaceholderTile()
                    } else {
                        ForEach(items) { item in
                            WallpaperTile(option: item, isSelected: selectionMatches(item)) {
                                onSelect(item.selection)
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .padding(.vertical, 6)
    }

    private func selectionMatches(_ option: WallpaperOption) -> Bool {
        let target = option.selection
        return selection.kind == target.kind && selection.id == target.id
    }
}

private struct WallpaperPlaceholderTile: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color(.separator).opacity(0.18), lineWidth: 0.5)
                )
            VStack(spacing: 6) {
                Image(systemName: "photo.on.rectangle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Upload")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 140, height: 90)
    }
}

private struct WallpaperTile: View {
    let option: WallpaperOption
    let isSelected: Bool
    let onSelect: () -> Void

    @EnvironmentObject private var theme: ThemeManager

    var body: some View {
        Button(action: onSelect) {
            ZStack(alignment: .bottomLeading) {
                ThemeBackground(configuration: configuration, ignoresSafeArea: false)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                if isSelected {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(theme.tokens.accent)
                                .padding(6)
                        }
                        Spacer()
                    }
                }
                Text(option.name)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.black.opacity(0.18))
                    )
                    .padding(6)
            }
            .frame(width: 140, height: 90)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? theme.tokens.accent.opacity(0.8) : Color(.separator).opacity(0.18), lineWidth: isSelected ? 2 : 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    private var configuration: ThemeConfiguration {
        var config = theme.configuration
        config.wallpaper = option.selection
        return config
    }
}

private struct AccentGrid: View {
    let accents: [ThemeAccent]
    let selectedAccent: ThemeAccent
    let onSelect: (ThemeAccent) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 6)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(accents) { accent in
                Button {
                    onSelect(accent)
                } label: {
                    ZStack {
                        Circle()
                            .fill(accent.color)
                            .frame(width: 28, height: 28)
                        if accent.id == selectedAccent.id {
                            Image(systemName: "checkmark")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.white)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct SurfaceSlider: View {
    let style: ThemeSurfaceStyle
    let onChange: (ThemeSurfaceStyle) -> Void

    @State private var sliderValue: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Slider(value: $sliderValue, in: 0...1)
                .onChange(of: sliderValue) { newValue in
                    onChange(style(for: newValue))
                }
                .onAppear {
                    sliderValue = value(for: style)
                }
                .onChange(of: style) { newValue in
                    sliderValue = value(for: newValue)
                }
            Text(label(for: style))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func value(for style: ThemeSurfaceStyle) -> Double {
        switch style {
        case .soft: return 0.0
        case .frosted: return 0.33
        case .gradient: return 0.66
        case .solid: return 1.0
        }
    }

    private func style(for value: Double) -> ThemeSurfaceStyle {
        switch value {
        case ..<0.25: return .soft
        case ..<0.5: return .frosted
        case ..<0.85: return .gradient
        default: return .solid
        }
    }

    private func label(for style: ThemeSurfaceStyle) -> String {
        "Surface: \(style.title)"
    }
}

private struct AllWallpapersView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var theme: ThemeManager

    let selection: ThemeWallpaperSelection
    let onSelect: (ThemeWallpaperSelection) -> Void

    var body: some View {
        NavigationStack {
            List {
                Section("Gradients") {
                    ForEach(ThemeWallpaperCatalog.gradients) { gradient in
                        WallpaperRow(
                            option: .gradient(gradient),
                            isSelected: selection.kind == .gradient && selection.id == gradient.id,
                            onSelect: { onSelect(ThemeWallpaperSelection(kind: .gradient, id: gradient.id, imageFilename: nil, imageMode: nil)) }
                        )
                    }
                }

                Section("Patterns") {
                    ForEach(ThemeWallpaperCatalog.patterns) { pattern in
                        WallpaperRow(
                            option: .pattern(pattern),
                            isSelected: selection.kind == .pattern && selection.id == pattern.id,
                            onSelect: { onSelect(ThemeWallpaperSelection(kind: .pattern, id: pattern.id, imageFilename: nil, imageMode: nil)) }
                        )
                    }
                }

                Section("Designer") {
                    ForEach(ThemeWallpaperCatalog.designers) { designer in
                        WallpaperRow(
                            option: .designer(designer),
                            isSelected: selection.kind == .designer && selection.id == designer.id,
                            onSelect: { onSelect(ThemeWallpaperSelection(kind: .designer, id: designer.id, imageFilename: nil, imageMode: nil)) }
                        )
                    }
                }

                if !theme.userWallpapers.isEmpty {
                    Section("Images") {
                        ForEach(theme.userWallpapers) { wallpaper in
                            WallpaperRow(
                                option: .image(wallpaper),
                                isSelected: selection.kind == .image && selection.id == wallpaper.id,
                                onSelect: { onSelect(ThemeWallpaperSelection(kind: .image, id: wallpaper.id, imageFilename: wallpaper.filename, imageMode: wallpaper.mode)) }
                            )
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("All Wallpapers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private struct WallpaperRow: View {
    let option: WallpaperOption
    let isSelected: Bool
    let onSelect: () -> Void

    @EnvironmentObject private var theme: ThemeManager

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                ThemeBackground(configuration: previewConfiguration, ignoresSafeArea: false)
                    .frame(width: 56, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                Text(option.name)
                    .foregroundStyle(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(theme.tokens.accent)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var previewConfiguration: ThemeConfiguration {
        var config = theme.configuration
        config.wallpaper = option.selection
        return config
    }
}
