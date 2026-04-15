import SwiftUI

private enum StoryDeckLayout {
    static let titleTopPadding: CGFloat = 54
    static let titleWidth: CGFloat = 333
    static let titleTracking: CGFloat = -0.87
    static let scientificTopSpacing: CGFloat = 12
    static let deckTopSpacing: CGFloat = 20
}

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
            let deckWidth = min(proxy.size.width - 32, 364)
            let titleFontSize = min(50, max(38, proxy.size.width * 0.11))

            ZStack(alignment: .top) {
                storyBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    VStack(spacing: StoryDeckLayout.scientificTopSpacing) {
                        Text(speciesLabel)
                            .font(.custom("Neue Haas Unica W1G", size: 10))
                            .tracking(0.25)
                            .foregroundStyle(GaiaColor.paperWhite500)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(GaiaColor.broccoliBrown300)
                            )

                        VStack(spacing: 0) {
                            Text("The Story of")
                                .font(.custom("NewSpirit-Medium", size: titleFontSize))
                                .tracking(StoryDeckLayout.titleTracking)

                            (
                                Text("a ")
                                    .font(.custom("NewSpirit-Medium", size: titleFontSize))
                                    .tracking(StoryDeckLayout.titleTracking)
                                + Text("Keystone")
                                    .font(.custom("NewSpirit-MediumItalic", size: titleFontSize))
                                    .tracking(StoryDeckLayout.titleTracking)
                            )
                        }
                        .foregroundStyle(GaiaColor.oliveGreen500)
                        .multilineTextAlignment(.center)
                        .frame(width: StoryDeckLayout.titleWidth)

                        Text(displaySummary)
                            .font(.custom("Neue Haas Unica W1G", size: 13))
                            .tracking(0.5)
                            .lineSpacing(4)
                            .foregroundStyle(GaiaColor.blackishGrey500)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .frame(width: StoryDeckLayout.titleWidth)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, StoryDeckLayout.titleTopPadding)

                    SwipeableStoryDeck(story: story, availableWidth: deckWidth)
                        .padding(.top, StoryDeckLayout.deckTopSpacing)

                    Spacer(minLength: 0)
                }

                HStack {
                    ToolbarGlassButton(icon: .back, accessibilityLabel: "Back") {
                        appState.closeStoryDeck()
                    }
                    Spacer()
                }
                .padding(.horizontal, GaiaSpacing.md)
                .safeAreaPadding(.top, GaiaSpacing.sm)
            }
        }
    }

    private var displaySummary: String {
        story.summary.replacingOccurrences(of: ". A disease", with: ".\nA disease")
    }

    private var storyBackground: some View {
        ZStack {
            Color(red: 252 / 255, green: 250 / 255, blue: 240 / 255)
            LinearGradient(
                stops: [
                    .init(color: Color(red: 252 / 255, green: 250 / 255, blue: 240 / 255).opacity(0.40), location: 0.13942),
                    .init(color: Color(red: 122 / 255, green: 158 / 255, blue: 93 / 255).opacity(0.40), location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}
