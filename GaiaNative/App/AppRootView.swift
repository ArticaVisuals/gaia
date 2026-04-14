import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var contentStore: ContentStore

    var body: some View {
        let selection = Binding(
            get: { appState.selectedSection },
            set: { appState.select(section: $0) }
        )

        TabView(selection: selection) {
            ForEach(AppSection.allCases) { section in
                AppRouter(section: section)
                    .toolbar(.hidden, for: .tabBar)
                    .tag(section)
                    .tabItem {
                        Image(section.tabAssetName)
                            .renderingMode(.original)
                        Text(section.title)
                    }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            BottomNavBar(selection: selection)
                .padding(.horizontal, GaiaSpacing.lg)
                .padding(.top, GaiaSpacing.md)
                .padding(.bottom, GaiaSpacing.sm)
                .background(Color.clear)
        }
        .tint(GaiaColor.olive)
        .preferredColorScheme(.light)
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
