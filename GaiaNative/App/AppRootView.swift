import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var contentStore: ContentStore
    @AppStorage("gaia.hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var dismissedForcedOnboarding = false

    var body: some View {
        Group {
            if shouldShowOnboarding {
                OnboardingFlowScreen {
                    hasCompletedOnboarding = true
                    dismissedForcedOnboarding = true
                    appState.select(section: .explore)
                }
            } else {
                mainAppShell
            }
        }
        .preferredColorScheme(.light)
    }

    private var shouldShowOnboarding: Bool {
        guard !launchArguments.contains("-gaiaSkipOnboarding") else {
            return false
        }

        if launchArguments.contains("-gaiaShowOnboarding") {
            return !dismissedForcedOnboarding
        }

        return !hasCompletedOnboarding
    }

    private var mainAppShell: some View {
        TabView(
            selection: Binding(
                get: { appState.selectedSection },
                set: { appState.select(section: $0) }
            )
        ) {
            ForEach(AppSection.allCases) { section in
                AppRouter(section: section)
                    .tag(section)
                    .tabItem {
                        Image(section.tabAssetName)
                            .renderingMode(.original)
                        Text(section.title)
                    }
            }
        }
        .tint(GaiaColor.olive)
        .fullScreenCover(isPresented: $appState.showsFindDetailsPrototype) {
            FindDetailsPrototypeScreen(species: selectedSpecies)
                .environmentObject(appState)
                .environmentObject(contentStore)
        }
        .fullScreenCover(isPresented: $appState.showsFindDetails) {
            FindDetailsScreen(species: selectedSpecies)
                .environmentObject(appState)
                .environmentObject(contentStore)
        }
        .fullScreenCover(isPresented: $appState.showsStoryDeck) {
            StoryDeckScreen(initialStoryID: appState.selectedStoryID)
                .environmentObject(appState)
                .environmentObject(contentStore)
        }
        .fullScreenCover(isPresented: $appState.showsProjectDetail) {
            ProjectDetailScreen(project: appState.selectedProject)
                .environmentObject(appState)
        }
    }

    private var selectedSpecies: Species {
        guard let selectedSpeciesID = appState.selectedSpeciesID,
              let species = contentStore.species.first(where: { $0.id == selectedSpeciesID }) else {
            return contentStore.primarySpecies
        }

        return species
    }

    private var launchArguments: Set<String> {
        Set(ProcessInfo.processInfo.arguments)
    }
}

private extension AppSection {
    var tabAssetName: String {
        switch self {
        case .explore:
            return "gaia-tab-explore-selected-32"
        case .log:
            return "gaia-tab-log-selected-32"
        case .observe:
            return "gaia-tab-observe-selected-32"
        case .activity:
            return "gaia-tab-activity-selected-32"
        case .profile:
            return "gaia-tab-profile-selected-32"
        }
    }
}
