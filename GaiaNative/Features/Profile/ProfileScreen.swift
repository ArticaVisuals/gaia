import SwiftUI

struct ProfileScreen: View {
    let forcedTab: ProfileTab?

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var contentStore: ContentStore
    @StateObject private var viewModel = ProfileViewModel()
    @State private var previousTab: ProfileTab = .impact

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: GaiaSpacing.lg) {
                ProfileHeaderCard(profile: contentStore.profile)
                    .padding(.horizontal, GaiaSpacing.md)

                DraggableTabSwitch(
                    tabs: ProfileTab.allCases,
                    selection: $viewModel.selectedTab,
                    title: { $0.rawValue }
                )
                .padding(.horizontal, GaiaSpacing.md)

                ZStack(alignment: .topLeading) {
                    tabContent(for: viewModel.selectedTab)
                        .id(viewModel.selectedTab)
                        .transition(tabTransition)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .animation(GaiaMotion.quickEase, value: viewModel.selectedTab)
                .animation(GaiaMotion.quickEase, value: previousTab)
                    .padding(.horizontal, GaiaSpacing.md)
                    .padding(.bottom, 120)
            }
        }
        .background(GaiaColor.surfacePrimary)
        .onAppear {
            let initialTab = forcedTab ?? appState.selectedProfileTab
            previousTab = initialTab
            viewModel.selectedTab = initialTab
        }
        .onChange(of: viewModel.selectedTab) { oldValue, newValue in
            previousTab = oldValue
            appState.selectedProfileTab = newValue
        }
    }

    @ViewBuilder
    private func tabContent(for tab: ProfileTab) -> some View {
        switch tab {
        case .impact:
            ProfileImpactTab(profile: contentStore.profile)
        case .community:
            ProfileCommunityTab(posts: contentStore.communityPosts)
        }
    }

    private var tabTransition: AnyTransition {
        let direction: CGFloat = tabDirection
        return .asymmetric(
            insertion: .offset(x: 26 * direction).combined(with: .opacity),
            removal: .offset(x: -26 * direction).combined(with: .opacity)
        )
    }

    private var tabDirection: CGFloat {
        guard let currentIndex = ProfileTab.allCases.firstIndex(of: viewModel.selectedTab),
              let previousIndex = ProfileTab.allCases.firstIndex(of: previousTab) else {
            return 1
        }

        return currentIndex >= previousIndex ? 1 : -1
    }
}
