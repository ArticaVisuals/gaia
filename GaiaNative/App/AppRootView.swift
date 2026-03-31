import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var contentStore: ContentStore

    var body: some View {
        ZStack {
            GaiaColor.surfacePrimary.ignoresSafeArea()

            AppRouter(section: appState.selectedSection)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(edges: .bottom)
        }
        .overlay(alignment: .bottom) {
            if appState.selectedSection != .observe {
                BottomNavBar(
                    selection: Binding(
                        get: { appState.selectedSection },
                        set: { appState.select(section: $0) }
                    )
                )
                .padding(.horizontal, GaiaSpacing.md)
                .padding(.bottom, 0)
                .offset(y: 20)
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
        .preferredColorScheme(.light)
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
    }

    private var selectedSpecies: Species {
        guard let selectedSpeciesID = appState.selectedSpeciesID,
              let species = contentStore.species.first(where: { $0.id == selectedSpeciesID }) else {
            return contentStore.primarySpecies
        }

        return species
    }
}
