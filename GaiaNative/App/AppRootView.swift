import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var contentStore: ContentStore
    @AppStorage("gaia.hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var dismissedForcedOnboarding = false

    var body: some View {
        Group {
            if let qaPreviewStory {
                StoryPreviewCardQAScreen(story: qaPreviewStory)
            } else if shouldShowOnboarding {
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
        .fullScreenCover(isPresented: $appState.showsFindDetails) {
            FindDetailsPrototypeScreen(species: selectedSpecies)
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

    private var qaPreviewStory: StoryCard? {
        guard let previewID = launchStoryPreviewCardID else {
            return nil
        }

        return contentStore.stories.first(where: { $0.id == previewID })
            ?? PreviewStories.all.first(where: { $0.id == previewID })
            ?? PreviewStories.keystone
    }

    private var launchStoryPreviewCardID: String? {
        let arguments = ProcessInfo.processInfo.arguments

        guard let flagIndex = arguments.firstIndex(of: "-gaiaStoryPreviewCard"),
              arguments.indices.contains(flagIndex + 1) else {
            return nil
        }

        return arguments[flagIndex + 1]
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

private struct StoryPreviewCardQAScreen: View {
    let story: StoryCard

    var body: some View {
        ZStack {
            GaiaColor.paperWhite50
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: GaiaSpacing.cardInset) {
                Text("Story")
                    .gaiaFont(.titleSans)
                    .foregroundStyle(GaiaColor.inkBlack300)

                StoryPreviewCard(story: story)
            }
            .frame(maxWidth: 370, alignment: .leading)
            .padding(.horizontal, GaiaSpacing.md)
        }
    }
}
