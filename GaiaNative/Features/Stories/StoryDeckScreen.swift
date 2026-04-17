import SwiftUI

private enum StoryDeckLayout {
    static let contentWidth: CGFloat = 353
    static let titleTopPadding: CGFloat = 42
    static let scientificLabelWidth: CGFloat = 159
    static let scientificLabelHeight: CGFloat = 32
    static let titleTracking: CGFloat = -0.87
    static let titleLineSpacing: CGFloat = -15.85
    static let scientificTopSpacing: CGFloat = 16
    static let deckTopSpacing: CGFloat = 48
}

// figma: https://www.figma.com/design/X0NcuRE0WKmsqR36cvlcij/Write-Test-Pro?node-id=22-1756
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
            let contentWidth = min(proxy.size.width - 49, StoryDeckLayout.contentWidth)
            let contentScale = max(0.9, min(1, contentWidth / StoryDeckLayout.contentWidth))
            let titleFontSize = 56 * contentScale

            ZStack(alignment: .top) {
                storyBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    VStack(spacing: StoryDeckLayout.deckTopSpacing * contentScale) {
                        VStack(spacing: StoryDeckLayout.scientificTopSpacing * contentScale) {
                            scientificNamePill(scale: contentScale)

                            VStack(spacing: StoryDeckLayout.titleLineSpacing * contentScale) {
                                Text("The Story of")
                                    .font(.custom("NewSpirit-Medium", size: titleFontSize))
                                    .tracking(StoryDeckLayout.titleTracking * contentScale)

                                (
                                    Text("a ")
                                        .font(.custom("NewSpirit-Medium", size: titleFontSize))
                                        .tracking(StoryDeckLayout.titleTracking * contentScale)
                                    + Text("Keystone")
                                        .font(.custom("NewSpirit-MediumItalic", size: titleFontSize))
                                        .tracking(StoryDeckLayout.titleTracking * contentScale)
                                )
                            }
                            .foregroundStyle(GaiaColor.oliveGreen500)
                            .multilineTextAlignment(.center)
                            .frame(width: contentWidth)
                        }
                        .frame(width: contentWidth)
                        .padding(.top, StoryDeckLayout.titleTopPadding * contentScale)

                        SwipeableStoryDeck(story: story, availableWidth: contentWidth)
                    }
                    .frame(maxWidth: .infinity)

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
        .statusBarHidden(true)
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

    private func scientificNamePill(scale: CGFloat) -> some View {
        Text(speciesLabel)
            .gaiaFont(.scientificLabel)
            .foregroundStyle(GaiaColor.paperWhite50)
            .multilineTextAlignment(.center)
            .frame(
                width: StoryDeckLayout.scientificLabelWidth * scale,
                height: StoryDeckLayout.scientificLabelHeight * scale
            )
            .background(
                Capsule(style: .continuous)
                    .fill(GaiaColor.broccoliBrown300)
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(GaiaColor.broccoliBrown200, lineWidth: 1)
                    )
            )
    }
}
