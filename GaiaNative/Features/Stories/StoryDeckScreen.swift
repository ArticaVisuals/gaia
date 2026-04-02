import SwiftUI

struct StoryDeckScreen: View {
    let initialStoryID: String?

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var contentStore: ContentStore

    private var story: StoryCard {
        guard let initialStoryID,
              let selected = contentStore.stories.first(where: { $0.id == initialStoryID }) else {
            return contentStore.stories.first ?? PreviewStories.keystone
        }

        return selected
    }

    private var speciesLabel: String {
        let selectedSpecies = contentStore.species.first(where: { $0.id == appState.selectedSpeciesID })
        return (selectedSpecies?.scientificName ?? contentStore.primarySpecies.scientificName).uppercased()
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                storyBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    VStack(spacing: 32) {
                        VStack(spacing: 16) {
                            Text(speciesLabel)
                                .font(.custom("Neue Haas Unica W1G", size: 10))
                                .tracking(0.25)
                                .foregroundStyle(GaiaColor.paperWhite500)
                                .padding(.horizontal, 12)
                                .frame(height: 20)
                                .background(GaiaColor.broccoliBrown300)
                                .clipShape(.capsule)

                            VStack(spacing: -6) {
                                Text("The Story of")
                                    .font(.custom("NewSpirit-Medium", size: 51))
                                    .minimumScaleFactor(0.88)

                                (
                                    Text("a ")
                                        .font(.custom("NewSpirit-Medium", size: 51))
                                    + Text("Keystone")
                                        .font(.custom("NewSpirit-MediumItalic", size: 51))
                                )
                                .minimumScaleFactor(0.88)
                            }
                            .foregroundStyle(GaiaColor.oliveGreen500)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 333)

                            Text(story.summary)
                                .font(.custom("Neue Haas Unica W1G", size: 15))
                                .tracking(0.5)
                                .foregroundStyle(GaiaColor.blackishGrey500)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: 333)
                        }
                        .frame(maxWidth: .infinity)

                        SwipeableStoryDeck(story: story, availableWidth: proxy.size.width - 40)
                    }
                    .padding(.top, 64)

                    Spacer(minLength: 0)
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

    private var storyBackground: some View {
        ZStack {
            GaiaColor.paperWhite50
            LinearGradient(
                stops: [
                    .init(color: GaiaColor.paperWhite500.opacity(0.40), location: 0.14),
                    .init(color: GaiaColor.grassGreen500.opacity(0.28), location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}
