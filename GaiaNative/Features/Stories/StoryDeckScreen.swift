import SwiftUI

struct StoryDeckScreen: View {
    let initialStoryID: String?
    var launchProgress: CGFloat = 1
    var onClose: (() -> Void)? = nil

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

    private var clampedLaunchProgress: CGFloat {
        min(max(launchProgress, 0), 1)
    }

    private enum Layout {
        static let contentTopInset: CGFloat = 64
        static let headerTopInset: CGFloat = 37
        static let sectionSpacing: CGFloat = 32
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                storyBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    VStack(spacing: Layout.sectionSpacing) {
                        VStack(spacing: GaiaSpacing.md) {
                            Text(speciesLabel)
                                .font(GaiaTypography.caption)
                                .tracking(GaiaTextStyle.caption.tracking)
                                .foregroundStyle(GaiaColor.paperWhite50)
                                .padding(.horizontal, GaiaSpacing.pillHorizontal)
                                .frame(height: 20)
                                .background(GaiaColor.broccoliBrown300)
                                .clipShape(.capsule)

                            VStack(spacing: -6) {
                                Text("The Story of")
                                    .font(GaiaTypography.heroMedium)
                                    .tracking(GaiaTextStyle.heroMedium.tracking)
                                    .minimumScaleFactor(0.88)

                                (
                                    Text("a ")
                                        .font(GaiaTypography.heroMedium)
                                        .tracking(GaiaTextStyle.heroMedium.tracking)
                                    + Text("Keystone")
                                        .font(GaiaTypography.heroMedium)
                                        .italic()
                                        .tracking(GaiaTextStyle.heroMedium.tracking)
                                )
                                .minimumScaleFactor(0.88)
                            }
                            .foregroundStyle(GaiaColor.oliveGreen500)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 333)
                            .opacity(Double(clampedLaunchProgress))
                            .offset(y: (1 - clampedLaunchProgress) * 18)

                            Text(story.summary)
                                .gaiaFont(.subheadline)
                                .foregroundStyle(GaiaColor.blackishGrey500)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: 333)
                                .opacity(Double(clampedLaunchProgress))
                                .offset(y: (1 - clampedLaunchProgress) * 14)
                        }
                        .padding(.top, Layout.headerTopInset)
                        .frame(maxWidth: .infinity)

                        SwipeableStoryDeck(story: story, availableWidth: proxy.size.width - 40)
                            .scaleEffect(0.93 + (0.07 * clampedLaunchProgress), anchor: .top)
                            .offset(y: (1 - clampedLaunchProgress) * 72)
                            .opacity(Double(clampedLaunchProgress))
                    }
                    .padding(.top, Layout.contentTopInset)

                    Spacer(minLength: 0)
                }

                HStack {
                    ToolbarGlassButton(icon: .back, accessibilityLabel: "Back") {
                        onClose?() ?? appState.closeStoryDeck()
                    }
                    Spacer()
                }
                .padding(.horizontal, GaiaSpacing.md)
                .safeAreaPadding(.top, 8)
                .opacity(Double(min(1, clampedLaunchProgress * 1.25)))
                .offset(y: (1 - clampedLaunchProgress) * 12)
            }
        }
    }

    private var storyBackground: some View {
        ZStack {
            GaiaColor.paperWhite50
            LinearGradient(
                stops: [
                    .init(color: GaiaColor.paperWhite50.opacity(0.40), location: 0.14),
                    .init(color: GaiaColor.grassGreen500.opacity(0.40), location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}
