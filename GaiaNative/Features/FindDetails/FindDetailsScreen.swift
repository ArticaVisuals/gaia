import SwiftUI

struct FindDetailsScreen: View {
    let species: Species

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var contentStore: ContentStore
    @StateObject private var viewModel = FindDetailsViewModel()

    var body: some View {
        ZStack(alignment: .top) {
            GaiaColor.surfacePrimary.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: GaiaSpacing.md) {
                    HeroCarousel(
                        imageNames: species.galleryAssetNames,
                        title: species.commonName,
                        subtitle: species.scientificName
                    )

                    DraggableTabSwitch(
                        tabs: FindDetailsTab.allCases,
                        selection: $viewModel.selectedTab,
                        title: { $0.rawValue }
                    )
                    .padding(.horizontal, GaiaSpacing.md)

                    tabContent
                        .padding(.bottom, 120)
                }
            }

            VStack {
                HStack {
                    ToolbarGlassButton(icon: .back, accessibilityLabel: "Back") {
                        appState.closeFindDetails()
                    }
                    Spacer()
                    ToolbarGlassPill(primaryAction: {}, secondaryAction: {})
                }
                .padding(.horizontal, GaiaSpacing.md)
                .safeAreaPadding(.top, 8)

                Spacer()
            }
        }
        .onAppear {
            viewModel.selectedTab = appState.selectedFindTab
        }
        .fullScreenCover(isPresented: $viewModel.showsExpandedMap) {
            LearnMapExpandedScreen(observations: contentStore.observations) {
                viewModel.showsExpandedMap = false
            }
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch viewModel.selectedTab {
        case .find:
            FindTabView(species: species)
        case .activity:
            ActivityTabView(events: contentStore.activityEvents)
        case .learn:
            LearnTabView(species: species, stories: contentStore.stories, onExpandMap: {
                viewModel.showsExpandedMap = true
            }, onOpenStory: { story in
                appState.openStoryDeck(story.id)
            })
        }
    }
}
