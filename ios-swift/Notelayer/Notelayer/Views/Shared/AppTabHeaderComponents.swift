import SwiftUI

struct AppHeaderLogo: View {
    var size: CGFloat = 32

    var body: some View {
        Image("NotelayerLogo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
            .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
    }
}

struct AppHeaderGearMenu: View {
    @EnvironmentObject private var authService: AuthService
    @StateObject private var store = LocalStore.shared

    let onAppearance: () -> Void
    let onCategoryManager: () -> Void
    let onProfileSettings: () -> Void

    var iconSize: CGFloat = 18
    var iconPadding: CGFloat = 6
    var badgeOffset: CGSize = CGSize(width: -4, height: 4)

    var body: some View {
        Menu {
            Button(action: onProfileSettings) {
                menuLabel("Profile & Settings", systemImage: "person.circle")
            }

            Button(action: onAppearance) {
                menuLabel("Colour Theme", systemImage: "paintbrush")
            }

            Button(action: onCategoryManager) {
                menuLabel("Manage Categories", systemImage: "tag")
            }

            if store.experimentalFeaturesEnabled {
                Button {
                    NotificationCenter.default.post(name: .openOnboardingRequested, object: nil)
                } label: {
                    menuLabel("Onboarding Guide", systemImage: "play.rectangle")
                }
            }

            Toggle(
                isOn: Binding(
                    get: { store.experimentalFeaturesEnabled },
                    set: { newValue in
                        store.setExperimentalFeaturesEnabled(newValue, source: "gear_menu")
                    }
                )
            ) {
                menuLabel(
                    store.experimentalFeaturesEnabled ? "Experimental Features (On)" : "Experimental Features",
                    systemImage: "flask"
                )
            }
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: iconSize))
                    .foregroundStyle(.secondary)
                    .padding(iconPadding)

                if authService.syncStatus.shouldShowBadge {
                    Circle()
                        .fill(authService.syncStatus.badgeColor == "red" ? Color.red : Color.yellow)
                        .frame(width: 10, height: 10)
                        .overlay(
                            Circle()
                                .stroke(Color(.systemBackground), lineWidth: 1.5)
                        )
                        .offset(x: badgeOffset.width, y: badgeOffset.height)
                        .accessibilityLabel(authService.syncStatus.badgeColor == "red" ? "Not signed in" : "Sync error")
                }
            }
        }
        .accessibilityIdentifier("app-header-gear-menu")
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func menuLabel(_ text: String, systemImage: String) -> some View {
        Label {
            Text(text)
                .lineLimit(1)
                .truncationMode(.tail)
        } icon: {
            Image(systemName: systemImage)
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}
