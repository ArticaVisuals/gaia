// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=875-23430
import SwiftUI
import UIKit

struct FindDetailsScreen: View {
    let species: Species

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var contentStore: ContentStore
    @StateObject private var viewModel = FindDetailsViewModel()
    @State private var isHorizontalTabSwipeActive = false

    private let mapDataService = MapDataService()

    var body: some View {
        GeometryReader { proxy in
            let topInset = proxy.safeAreaInsets.top > 0 ? proxy.safeAreaInsets.top : windowSafeTopInset
            // Keep hero under the glass toolbar while avoiding the overly tight top crop.
            let heroLift = max(topInset - GaiaSpacing.lg, 0)

            ZStack(alignment: .top) {
                GaiaColor.surfacePrimary.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                        HeroCarousel(
                            imageNames: species.galleryAssetNames,
                            title: species.commonName,
                            subtitle: species.scientificName
                        )
                        .padding(.top, -heroLift)
                        .frame(maxWidth: .infinity)

                        DraggableTabSwitch(
                            tabs: FindDetailsTab.allCases,
                            selection: $viewModel.selectedTab,
                            title: { $0.rawValue }
                        )
                        .frame(maxWidth: .infinity)

                        tabContent
                            .padding(.bottom, 120)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .horizontalTabSwipe(
                                tabs: FindDetailsTab.allCases,
                                selection: $viewModel.selectedTab,
                                onHorizontalDragStateChange: { isActive in
                                    isHorizontalTabSwipeActive = isActive
                                }
                            )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .scrollDisabled(isHorizontalTabSwipeActive)

                VStack {
                    HStack {
                        ToolbarGlassButton(icon: .back, accessibilityLabel: "Back") {
                            appState.closeFindDetails()
                        }
                        Spacer()
                        ToolbarGlassPill(primaryAction: {}, secondaryAction: {})
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, GaiaSpacing.md)
                    .padding(.top, max(topInset + 8, 54))

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            viewModel.selectedTab = appState.selectedFindTab
        }
        .fullScreenCover(isPresented: $viewModel.showsExpandedMap) {
            LearnMapExpandedScreen(observations: speciesObservations) {
                viewModel.showsExpandedMap = false
            }
        }
    }

    private var windowSafeTopInset: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .safeAreaInsets.top ?? 0
    }

    @ViewBuilder
    private var tabContent: some View {
        switch viewModel.selectedTab {
        case .find:
            FindTabView(
                species: species,
                observations: speciesObservations,
                onExpandMap: { viewModel.showsExpandedMap = true },
                onOpenProject: { project in
                    appState.openProjectDetail(project)
                }
            )
        case .activity:
            ActivityTabView(species: species)
        case .learn:
            LearnTabView(species: species, stories: contentStore.stories, onExpandMap: {
                viewModel.showsExpandedMap = true
            }, onOpenStory: { story in
                appState.openStoryDeck(story.id)
            })
        }
    }

    private var speciesObservations: [Observation] {
        let filtered = contentStore.observations.filter { $0.speciesID == species.id }
        guard filtered.isEmpty else {
            return mapDataService.expandedObservations(
                from: filtered,
                targetCount: 150,
                seed: "\(species.id)-find-map"
            )
        }

        return [
            Observation(
                id: "\(species.id)-detail-preview",
                speciesID: species.id,
                latitude: species.mapCoordinate.latitude,
                longitude: species.mapCoordinate.longitude,
                thumbnailAssetName: species.galleryAssetNames.first
            )
        ]
    }
}
