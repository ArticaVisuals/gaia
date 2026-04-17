import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var contentStore: ContentStore

    var body: some View {
        let selection = Binding(
            get: { appState.selectedSection },
            set: { appState.select(section: $0) }
        )

        tabs(selection: selection)
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

    private func tabs(selection: Binding<AppSection>) -> some View {
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
