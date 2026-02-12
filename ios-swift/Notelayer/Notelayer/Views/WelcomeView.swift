import SwiftUI

private enum OnboardingStep {
    case video
    case cues
    case presets
}

private struct OnboardingPreset: Identifiable {
    let id: String
    let name: String
    let isRecommended: Bool
    let categories: [(id: String, name: String, icon: String)]

    static let everydayBalance = OnboardingPreset(
        id: "everyday-balance",
        name: "Everyday Balance",
        isRecommended: true,
        categories: [
            ("personal", "Personal", "🧠"),
            ("work", "Work", "💼"),
            ("home", "Home", "🏠"),
            ("health", "Health", "🩺"),
            ("finance", "Finance and Investing", "📈"),
            ("someday", "Someday", "🗂️")
        ]
    )

    static let lifeAdmin = OnboardingPreset(
        id: "life-admin",
        name: "Life Admin",
        isRecommended: false,
        categories: [
            ("personal-admin", "Personal Admin", "📋"),
            ("errands", "Errands", "🛒"),
            ("family-home", "Family and Home", "👨‍👩‍👧‍👦"),
            ("health-wellness", "Health and Wellness", "🧘"),
            ("banking-bills", "Banking and Bills", "🏦"),
            ("someday", "Someday", "🗂️")
        ]
    )

    static let growthAndProjects = OnboardingPreset(
        id: "growth-projects",
        name: "Growth and Projects",
        isRecommended: false,
        categories: [
            ("work-projects", "Work Projects", "🧱"),
            ("personal-projects", "Personal Projects", "🛠️"),
            ("learning", "Learning", "📚"),
            ("relationships", "Relationships", "🤝"),
            ("finance", "Finance and Investing", "📈"),
            ("someday", "Someday", "🗂️")
        ]
    )

    static let all: [OnboardingPreset] = [.everydayBalance, .lifeAdmin, .growthAndProjects]

    func makeCategories() -> [Category] {
        categories.enumerated().map { index, category in
            Category(
                id: category.id,
                name: category.name,
                icon: category.icon,
                color: CategoryColorDefaults.defaultHex(forCategoryId: category.id),
                order: index
            )
        }
    }
}

/// First-install onboarding flow: video intro, contextual cues, and starter categories.
struct WelcomeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var theme: ThemeManager
    @StateObject private var store = LocalStore.shared

    @State private var step: OnboardingStep = .video
    @State private var canSkipVideo = false
    @State private var selectedPresetID = OnboardingPreset.everydayBalance.id

    let onDismiss: () -> Void

    private var selectedPreset: OnboardingPreset {
        OnboardingPreset.all.first(where: { $0.id == selectedPresetID }) ?? .everydayBalance
    }

    var body: some View {
        NavigationStack {
            ZStack {
                theme.tokens.screenBackground.ignoresSafeArea()
                ThemeBackground(configuration: theme.configuration)

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        switch step {
                        case .video:
                            videoStep
                        case .cues:
                            cuesStep
                        case .presets:
                            presetsStep
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Get Started")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Skip") {
                        finishOnboarding()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    switch step {
                    case .video:
                        Button("Next") {
                            step = .cues
                        }
                    case .cues:
                        Button("Next") {
                            step = .presets
                        }
                    case .presets:
                        EmptyView()
                    }
                }
            }
        }
        .onAppear {
            if step == .video {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    canSkipVideo = true
                }
            }
        }
    }

    private var videoStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Orientation")
                .font(.title3.bold())

            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .frame(height: 220)
                VStack(spacing: 10) {
                    Image(systemName: "play.rectangle.fill")
                        .font(.system(size: 38))
                        .foregroundStyle(theme.tokens.accent)
                    Text("Intro video placeholder")
                        .font(.headline)
                    Text("Video-first walkthrough of task entry, category grouping, and Insights.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
            }

            if canSkipVideo {
                Button("Skip Intro Video") {
                    step = .cues
                }
                .font(.subheadline)
            } else {
                Text("Skip available in a moment…")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var cuesStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How Notelayer Works")
                .font(.title3.bold())

            cueRow(icon: "checkmark.circle", text: "Tasks can live in multiple categories.")
            cueRow(icon: "line.3.horizontal.decrease.circle", text: "Switch views to organize by list, priority, category, or date.")
            cueRow(icon: "flask", text: "Experimental features can be enabled later from the gear menu.")

            Text("This flow stays lightweight and can be reopened from Settings.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var presetsStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose Starting Categories")
                .font(.title3.bold())

            ForEach(OnboardingPreset.all) { preset in
                Button {
                    selectedPresetID = preset.id
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(preset.name)
                                .font(.headline)
                            if preset.isRecommended {
                                Text("Recommended")
                                    .font(.caption.weight(.semibold))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(theme.tokens.accent.opacity(0.18), in: Capsule())
                            }
                            Spacer()
                            Image(systemName: selectedPresetID == preset.id ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selectedPresetID == preset.id ? theme.tokens.accent : .secondary)
                        }

                        Text(preset.categories.map { "\($0.icon) \($0.name)" }.joined(separator: "  •  "))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(selectedPresetID == preset.id ? theme.tokens.accent.opacity(0.7) : Color.clear, lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
            }

            Button("Start with \(selectedPreset.name)") {
                store.applyOnboardingPresetCategories(selectedPreset.makeCategories())
                finishOnboarding()
            }
            .buttonStyle(.borderedProminent)

            Button("Keep Current Categories") {
                finishOnboarding()
            }
            .buttonStyle(.bordered)
            .font(.subheadline)
        }
    }

    private func cueRow(icon: String, text: String) -> some View {
        Label {
            Text(text)
        } icon: {
            Image(systemName: icon)
                .foregroundStyle(theme.tokens.accent)
        }
        .font(.subheadline)
    }

    private func finishOnboarding() {
        onDismiss()
        dismiss()
    }
}

#Preview {
    WelcomeView(onDismiss: {})
        .environmentObject(ThemeManager.shared)
}
