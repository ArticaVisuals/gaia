import SwiftUI

enum StoryDeckVisualStyle {
    static let brandPrimary = Color(.sRGB, red: 107.0 / 255.0, green: 131.0 / 255.0, blue: 82.0 / 255.0)
    static let brandGlow = Color(.sRGB, red: 122.0 / 255.0, green: 158.0 / 255.0, blue: 93.0 / 255.0)
    static let inactivePageDot = Color(.sRGB, red: 173.0 / 255.0, green: 186.0 / 255.0, blue: 159.0 / 255.0)
    static let titleTracking: CGFloat = -0.8699
    static let titleLineSpacing: CGFloat = (55.674 * 0.97) - 55.674
    static let summaryTracking: CGFloat = 0.5
    static let summaryLineSpacing: CGFloat = (15 * 1.3) - 15
    static let speciesLabelTracking: CGFloat = 0.25
    static let backgroundGlowOpacity: Double = 0.30
    static let deckLift: CGFloat = -10
}

enum StoryDeckTypography {
    static let hero = StoryDeckFontResolver.serif(size: 55.674, weight: .medium)
    static let heroItalic = StoryDeckFontResolver.serifItalic(size: 55.674, weight: .medium)
    static let speciesLabel = StoryDeckFontResolver.sans(size: 10, weight: .regular)
}

private enum StoryDeckFontResolver {
    static func serif(size: CGFloat, weight: Font.Weight) -> Font {
        if let name = serifCandidates(for: weight).first(where: { UIFont(name: $0, size: size) != nil }) {
            return .custom(name, size: size)
        }

        return .system(size: size, weight: weight, design: .serif)
    }

    static func serifItalic(size: CGFloat, weight: Font.Weight) -> Font {
        if let name = serifItalicCandidates(for: weight).first(where: { UIFont(name: $0, size: size) != nil }) {
            return .custom(name, size: size)
        }

        return .system(size: size, weight: weight, design: .serif).italic()
    }

    static func sans(size: CGFloat, weight: Font.Weight) -> Font {
        if let name = [
            "neue-haas-unica",
            postScriptName(base: "Neue Haas Unica", weight: weight),
            postScriptName(base: "NeueHaasUnica", weight: weight),
            "Neue Haas Unica",
            "Neue Haas Unica W1G",
            "NeueHaasUnica",
            "NeueHaasUnica-Regular",
            "NeueHaasUnica-Medium",
            "NeueHaasUnica-Bold"
        ].first(where: { UIFont(name: $0, size: size) != nil }) {
            return .custom(name, size: size)
        }

        return .system(size: size, weight: weight, design: .default)
    }

    private static func serifCandidates(for weight: Font.Weight) -> [String] {
        switch weight {
        case .bold:
            return [
                "NewSpirit-SemiBold",
                "NewSpirit-Bold",
                "NewSpirit-SemiBoldItalic",
                "NewSpirit-BoldItalic",
                "new-spirit",
                "NewSpirit"
            ]
        case .medium:
            return [
                "NewSpirit-Medium",
                "NewSpirit-SemiBold",
                "NewSpirit-MediumItalic",
                "NewSpirit-SemiBoldItalic",
                "new-spirit",
                "NewSpirit"
            ]
        default:
            return [
                "NewSpirit-Regular",
                "NewSpirit-Light",
                "NewSpirit-RegularItalic",
                "new-spirit",
                "NewSpirit"
            ]
        }
    }

    private static func serifItalicCandidates(for weight: Font.Weight) -> [String] {
        switch weight {
        case .bold:
            return [
                "NewSpirit-BoldItalic",
                "NewSpirit-SemiBoldItalic",
                "NewSpirit-MediumItalic",
                "new-spirit",
                "NewSpirit"
            ]
        case .medium:
            return [
                "NewSpirit-MediumItalic",
                "NewSpirit-SemiBoldItalic",
                "NewSpirit-RegularItalic",
                "new-spirit",
                "NewSpirit"
            ]
        default:
            return [
                "NewSpirit-RegularItalic",
                "NewSpirit-LightItalic",
                "new-spirit",
                "NewSpirit"
            ]
        }
    }

    private static func postScriptName(base: String, weight: Font.Weight) -> String {
        switch weight {
        case .heavy, .black:
            return "\(base)-ExtraBold"
        case .bold:
            return "\(base)-Bold"
        case .medium:
            return "\(base)-Medium"
        default:
            return "\(base)-Regular"
        }
    }
}

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
            let contentTopPadding = max(0, Layout.contentTopInset - proxy.safeAreaInsets.top)

            ZStack(alignment: .top) {
                storyBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    VStack(spacing: Layout.sectionSpacing) {
                        VStack(spacing: GaiaSpacing.md) {
                            Text(speciesLabel)
                                .font(StoryDeckTypography.speciesLabel)
                                .tracking(StoryDeckVisualStyle.speciesLabelTracking)
                                .foregroundStyle(GaiaColor.paperWhite50)
                                .padding(.horizontal, GaiaSpacing.pillHorizontal)
                                .frame(height: 20)
                                .background(GaiaColor.broccoliBrown300)
                                .clipShape(.capsule)

                            storyTitleView
                                .frame(maxWidth: 333)
                                .fixedSize(horizontal: false, vertical: true)
                                .opacity(Double(clampedLaunchProgress))
                                .offset(y: (1 - clampedLaunchProgress) * 18)

                            Text(story.summary)
                                .font(GaiaTypography.subheadline)
                                .tracking(StoryDeckVisualStyle.summaryTracking)
                                .lineSpacing(StoryDeckVisualStyle.summaryLineSpacing)
                                .foregroundStyle(GaiaColor.textSecondary)
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
                            .offset(y: StoryDeckVisualStyle.deckLift + ((1 - clampedLaunchProgress) * 72))
                            .opacity(Double(clampedLaunchProgress))
                    }
                    .padding(.top, contentTopPadding)

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
        .statusBarHidden(true)
    }

    private var storyTitleLines: [String] {
        story.title
            .components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    private var storyTitleView: some View {
        Text(storyTitleAttributedText)
            .tracking(StoryDeckVisualStyle.titleTracking)
            .lineSpacing(StoryDeckVisualStyle.titleLineSpacing)
            .foregroundStyle(StoryDeckVisualStyle.brandPrimary)
            .lineLimit(2)
            .minimumScaleFactor(0.94)
            .multilineTextAlignment(.center)
    }

    private var storyTitleAttributedText: AttributedString {
        let firstLine = storyTitleLines.first ?? story.title
        let remainingLines = storyTitleLines.dropFirst()
        let titleString: String

        if remainingLines.isEmpty {
            titleString = firstLine
        } else {
            titleString = firstLine + "\n" + remainingLines.joined(separator: " ")
        }

        var attributed = AttributedString(titleString)
        attributed.font = StoryDeckTypography.hero

        if let keystoneRange = attributed.range(of: "Keystone") {
            attributed[keystoneRange].font = StoryDeckTypography.heroItalic
        }

        return attributed
    }

    private var storyBackground: some View {
        ZStack {
            GaiaColor.paperWhite50
            LinearGradient(
                stops: [
                    .init(color: GaiaColor.paperWhite50.opacity(0.40), location: 0.14),
                    .init(color: StoryDeckVisualStyle.brandGlow.opacity(StoryDeckVisualStyle.backgroundGlowOpacity), location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}
