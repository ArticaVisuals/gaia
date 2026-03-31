import SwiftUI

struct StoryDeckScreen: View {
    let initialStoryID: String?

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var contentStore: ContentStore

    private var orderedStories: [StoryCard] {
        guard let initialStoryID,
              let selected = contentStore.stories.first(where: { $0.id == initialStoryID }) else {
            return contentStore.stories
        }

        return [selected] + contentStore.stories.filter { $0.id != selected.id }
    }

    var body: some View {
        ZStack(alignment: .top) {
            GaiaColor.surfacePrimary.ignoresSafeArea()

            VStack(spacing: GaiaSpacing.lg) {
                SwipeableStoryDeck(stories: orderedStories)
                    .padding(.top, 96)
                Spacer()
            }

            HStack {
                ToolbarGlassButton(icon: .back, accessibilityLabel: "Back") {
                    appState.closeStoryDeck()
                }
                Spacer()
            }
            .padding(.horizontal, GaiaSpacing.md)
            .safeAreaPadding(.top, 8)
        }
    }
}
