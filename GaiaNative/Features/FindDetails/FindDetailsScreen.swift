import SwiftUI
import UIKit

struct FindDetailsScreen: View {
    let species: Species

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var contentStore: ContentStore
    @StateObject private var viewModel = FindDetailsViewModel()

    var body: some View {
        GeometryReader { proxy in
            let topInset = proxy.safeAreaInsets.top > 0 ? proxy.safeAreaInsets.top : windowSafeTopInset

            ZStack(alignment: .top) {
                GaiaColor.surfacePrimary.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: GaiaSpacing.md) {
                        HeroCarousel(
                            imageNames: species.galleryAssetNames,
                            title: species.commonName,
                            subtitle: species.scientificName
                        )
                        .padding(.top, -topInset)

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
                    .padding(.top, max(topInset + 8, 54))

                    Spacer()
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            viewModel.selectedTab = appState.selectedFindTab
        }
        .fullScreenCover(isPresented: $viewModel.showsExpandedMap) {
            LearnMapExpandedScreen(observations: contentStore.observations) {
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
