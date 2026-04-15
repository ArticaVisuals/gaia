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
                    .tag(section)
                    .tabItem {
                        AppTabItemLabel(
                            section: section,
                            isSelected: appState.selectedSection == section
                        )
                    }
            }
        }
        .tint(GaiaColor.olive)
        .preferredColorScheme(.light)
        .fullScreenCover(isPresented: $appState.showsFindDetailsPrototype) {
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
}

private extension AppSection {
    func tabAssetName(isSelected: Bool) -> String {
        switch self {
        case .explore:
            return isSelected ? "gaia-tab-explore-selected-32" : "gaia-tab-explore-deselected-32"
        case .log:
            return isSelected ? "gaia-tab-log-selected-32" : "gaia-tab-log-deselected-32"
        case .observe:
            return isSelected ? "gaia-tab-observe-selected-32" : "gaia-tab-observe-deselected-32"
        case .activity:
            return isSelected ? "gaia-tab-activity-selected-32" : "gaia-tab-activity-deselected-32"
        case .profile:
            return isSelected ? "gaia-tab-profile-selected-32" : "gaia-tab-profile-deselected-32"
        }
    }
}

private struct AppTabItemLabel: View {
    let section: AppSection
    let isSelected: Bool

    private var titleColor: Color {
        isSelected ? GaiaColor.olive : GaiaColor.oliveGreen200
    }

    var body: some View {
        Label {
            Text(section.title)
                .foregroundStyle(titleColor)
        } icon: {
            Image(section.tabAssetName(isSelected: isSelected))
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
        }
    }
}
