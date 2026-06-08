import SwiftUI

private enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case categories = 1
    case taskEntry = 2
    case done = 3
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

/// Four-step onboarding: welcome splash, category selection, first task entry, celebration.
struct WelcomeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var theme: ThemeManager
    @StateObject private var store = LocalStore.shared

    @State private var step: OnboardingStep = .welcome
    @State private var selectedPresetID: String? = OnboardingPreset.everydayBalance.id
    @State private var firstTaskText: String = ""
    @State private var didAddFirstTask = false
    @State private var presetCategories: [Category] = []
    @State private var selectedTaskCategories: Set<String> = []

    let onDismiss: () -> Void

    private var selectedPreset: OnboardingPreset? {
        guard let selectedPresetID, selectedPresetID != "blank" else { return nil }
        return OnboardingPreset.all.first(where: { $0.id == selectedPresetID })
    }

    private var progressDots: some View {
        HStack(spacing: 6) {
            ForEach(OnboardingStep.allCases, id: \.self) { s in
                Capsule()
                    .fill(s.rawValue <= step.rawValue ? theme.tokens.accent : Color.secondary.opacity(0.25))
                    .frame(width: s == step ? 22 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: step)
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                theme.tokens.screenBackground.ignoresSafeArea()
                ThemeBackground(configuration: theme.configuration)

                ScrollView {
                    VStack(alignment: .center, spacing: 24) {
                        switch step {
                        case .welcome:
                            welcomeStep
                        case .categories:
                            categoriesStep
                        case .taskEntry:
                            taskEntryStep
                        case .done:
                            doneStep
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EmptyView()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EmptyView()
                }
            }
        }
        .interactiveDismissDisabled()
    }

    // MARK: — Step 1: Welcome

    private var welcomeStep: some View {
        VStack(alignment: .center, spacing: 20) {
            Spacer(minLength: 40)

            AppHeaderLogo(size: 72)

            VStack(alignment: .center, spacing: 8) {
                Text("Your tasks. Actually organised.")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)

                Text("Takes about 60 seconds to get set up.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer(minLength: 40)

            Button("Get Started") {
                withAnimation(.easeInOut(duration: 0.2)) {
                    step = .categories
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(theme.tokens.accent)

            Spacer(minLength: 40)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: — Step 2: Categories

    private var categoriesStep: some View {
        VStack(alignment: .center, spacing: 20) {
            progressDots
                .padding(.bottom, 8)

            VStack(alignment: .center, spacing: 8) {
                Text("What does your life look like?")
                    .font(.title3.bold())

                Text("Pick a starting point — you can always customise later.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                ForEach(OnboardingPreset.all) { preset in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedPresetID = preset.id
                        }
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

                // Start blank option
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        selectedPresetID = "blank"
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Start blank")
                                .font(.headline)
                            Spacer()
                            Image(systemName: selectedPresetID == "blank" ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selectedPresetID == "blank" ? theme.tokens.accent : .secondary)
                        }
                        Text("No starting categories")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(selectedPresetID == "blank" ? theme.tokens.accent.opacity(0.7) : Color.clear, lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
            }

            let ctaLabel = selectedPresetID == "blank" ? "Start blank" : "Start with \(selectedPreset?.name ?? "Everyday Balance")"
            Button(ctaLabel) {
                if let preset = selectedPreset {
                    let categories = preset.makeCategories()
                    store.applyOnboardingPresetCategories(categories)
                    presetCategories = categories
                    selectedTaskCategories = []
                } else {
                    presetCategories = []
                    selectedTaskCategories = []
                }
                withAnimation(.easeInOut(duration: 0.2)) {
                    step = .taskEntry
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(theme.tokens.accent)

            Spacer(minLength: 20)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: — Step 3: Add First Task

    private var taskEntryStep: some View {
        VStack(alignment: .center, spacing: 20) {
            progressDots
                .padding(.bottom, 8)

            VStack(alignment: .center, spacing: 8) {
                Text("Add something on your mind")
                    .font(.title3.bold())

                Text("Even one task. You can add more anytime.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            TextField("e.g. Call the dentist", text: $firstTaskText)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                )

            if !presetCategories.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Add to categories (optional)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    FlowLayout(spacing: 8) {
                        ForEach(presetCategories) { category in
                            CategoryChip(
                                category: category,
                                isSelected: selectedTaskCategories.contains(category.id),
                                onTap: {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        if selectedTaskCategories.contains(category.id) {
                                            selectedTaskCategories.remove(category.id)
                                        } else {
                                            selectedTaskCategories.insert(category.id)
                                        }
                                    }
                                }
                            )
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                addFirstTask()
            } label: {
                Text("Add Task")
            }
            .buttonStyle(.borderedProminent)
            .tint(theme.tokens.accent)
            .disabled(firstTaskText.trimmingCharacters(in: .whitespaces).isEmpty)

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    step = .done
                }
            } label: {
                Text("Skip for now")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)

            Spacer(minLength: 20)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: — Step 4: Done

    private var doneStep: some View {
        VStack(alignment: .center, spacing: 20) {
            Spacer(minLength: 40)

            progressDots
                .padding(.bottom, 8)

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(theme.tokens.accent)
                .transition(.scale.combined(with: .opacity))

            VStack(alignment: .center, spacing: 8) {
                Text("You're set up.")
                    .font(.title2.bold())

                Text(didAddFirstTask ? "Your first task is waiting." : "Your categories are ready.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 40)

            Button("Let's go") {
                finishOnboarding()
            }
            .buttonStyle(.borderedProminent)
            .tint(theme.tokens.accent)

            Spacer(minLength: 40)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .onAppear {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                // Trigger the checkmark animation
            }
        }
    }

    // MARK: — Helpers

    private func addFirstTask() {
        let trimmed = firstTaskText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let newTask = Task(
            title: trimmed,
            categories: Array(selectedTaskCategories)
        )
        store.addTask(newTask)
        didAddFirstTask = true
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            step = .done
        }
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
