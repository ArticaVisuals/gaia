import SwiftUI
import UIKit

// figma: https://www.figma.com/design/X0NcuRE0WKmsqR36cvlcij/Write-Test-Pro?node-id=22-1599&m=dev

private enum FindDetailsLearnLayout {
    static let horizontalInset: CGFloat = GaiaSpacing.md
    static let sectionSpacing: CGFloat = GaiaSpacing.xl
    static let sectionTitleSpacing: CGFloat = GaiaSpacing.cardInset
    static let introSpacing: CGFloat = GaiaSpacing.cardContentInsetWide
    static let contentTopPadding: CGFloat = 59
    static let summaryWidth: CGFloat = 326
    static let summaryTextColor = GaiaColor.paperWhite600
    static let statsCardWidth: CGFloat = 117.961
    static let statsCardHeight: CGFloat = 101.083
    static let statsCardCornerRadius: CGFloat = 16.116
    static let statsCardBorderWidth: CGFloat = 1.007
    static let statsCardInset: CGFloat = 12.087
    static let statsCardContentGap: CGFloat = 12.087
    static let statsContentHeight: CGFloat = 55.821
    static let statsCategoryIconWidth: CGFloat = 53.711
    static let statsCategoryIconHeight: CGFloat = 53.721
    static let statsStatusWidth: CGFloat = 54.394
    static let statsStatusHeight: CGFloat = 55.224
    static let statsStatusStrokeWidth: CGFloat = 3.288
    static let statsGap: CGFloat = GaiaSpacing.sm
    static let galleryHeight: CGFloat = 240
    static let galleryCornerRadius: CGFloat = 16.371
    static let galleryBorderWidth: CGFloat = 0.83
    static let galleryItemSpacing: CGFloat = GaiaSpacing.sm
    static let gallerySectionSpacing: CGFloat = GaiaSpacing.cardInset
    static let galleryPageControlHorizontalPadding: CGFloat = GaiaSpacing.lg
    static let galleryPageControlCornerRadius: CGFloat = 50
    static let galleryLandscapeWidth: CGFloat = 370
    static let gallerySquareWidth: CGFloat = 239.918
    static let galleryAlternateLandscapeWidth: CGFloat = 389.867
    static let pageDotSize: CGFloat = GaiaSpacing.sm
    static let mapHeight: CGFloat = 214
    static let mapCornerRadius: CGFloat = 16
    static let mapExpandInset: CGFloat = 11.222
    static let mapExpandBadgeSize: CGFloat = 40.001
    static let mapExpandIconSize: CGFloat = 26.667
    static let listCardCornerRadius: CGFloat = 16
    static let listCardHeight: CGFloat = 112.556
    static let listImageSize: CGFloat = 88.556
    static let listImageCornerRadius: CGFloat = GaiaRadius.thumbnail
    static let listContentGap: CGFloat = GaiaSpacing.gapLg
    static let listTextSpacing: CGFloat = GaiaSpacing.cardInset
    static let listTextColumnWidth: CGFloat = 202.924
    static let listCardBorderWidth: CGFloat = 1
    static let recentActivityHeaderSpacing: CGFloat = GaiaSpacing.gapLg
    static let recentActivityFooterTopPadding: CGFloat = GaiaSpacing.gapLg
    static let leaderboardShellCornerRadius: CGFloat = GaiaRadius.lg
    static let leaderboardShellBorderWidth: CGFloat = 1
    static let leaderboardInnerCornerRadius: CGFloat = 15.044
    static let leaderboardInnerBorderWidth: CGFloat = 0.94
    static let leaderboardRowHeight: CGFloat = 56
    static let leaderboardRowOverlap: CGFloat = 0.901
    static let leaderboardRankBadgeSize: CGFloat = 20.09
    static let leaderboardAvatarSize: CGFloat = 28.842
    static let highlightedLeaderboardAvatarSize: CGFloat = 30.843
    static let leaderboardDefaultHorizontalInset: CGFloat = GaiaSpacing.md
    static let leaderboardHighlightedHorizontalInset: CGFloat = 15.422
    static let leaderboardHighlightedVerticalInset: CGFloat = 11.566
    static let leaderboardDefaultRankGap: CGFloat = 14.421
    static let leaderboardHighlightedRankGap: CGFloat = 15.422
    static let leaderboardDefaultProfileGap: CGFloat = 7.211
    static let leaderboardHighlightedProfileGap: CGFloat = 7.711
    static let leaderboardDefaultPointsGap: CGFloat = 3.605
    static let leaderboardHighlightedPointsGap: CGFloat = 3.855
    static let leaderboardRankStrokeWidth: CGFloat = 0.423
    static let leaderboardDefaultAvatarBorderWidth: CGFloat = 0.3
    static let leaderboardHighlightedAvatarBorderWidth: CGFloat = 0.321
    static let leaderboardDefaultRankTracking: CGFloat = -0.1672
    static let leaderboardHighlightedRankTracking: CGFloat = -1.0258
    static let leaderboardHighlightedPointsTracking: CGFloat = -0.2988
    static let leaderboardViewAllTopPadding: CGFloat = GaiaSpacing.cardInset
    static let footerBottomPadding: CGFloat = GaiaSpacing.xxl
    static let projectCardSpacing: CGFloat = GaiaSpacing.lg
    static let projectCardContentSpacing: CGFloat = GaiaSpacing.md
    static let projectCardTitleSpacing: CGFloat = GaiaSpacing.gapMd
    static let projectCardSummaryWidth: CGFloat = 236
    static let projectCardButtonMinHeight: CGFloat = 50
}

private struct FindDetailsLearnRecentItem: Identifiable {
    let id: String
    let dayLabel: String
    let locationText: String
    let imageName: String
}

private struct FindDetailsLeaderboardEntry: Identifiable {
    let id: String
    let rank: String
    let name: String
    let points: String
    let highlighted: Bool
    let avatarImageName: String
}

struct FindDetailsLearnScreen: View {
    let species: Species
    let observations: [Observation]
    let stories: [StoryCard]
    let dismiss: () -> Void
    let onOpenStory: (StoryCard) -> Void

    @State private var selectedGalleryIndex: Int? = 0
    @State private var showsExpandedMap = false

    private enum ScrollMarker: Hashable {
        case recentActivity
        case project
    }

    private var galleryImages: [String] {
        let images = Array(species.galleryAssetNames.dropFirst())
        return images.isEmpty ? ["coast-live-oak-gallery-1"] : images
    }

    private var galleryCards: [FindDetailsLearnGalleryCard] {
        let widths = [
            FindDetailsLearnLayout.galleryLandscapeWidth,
            FindDetailsLearnLayout.gallerySquareWidth,
            FindDetailsLearnLayout.galleryAlternateLandscapeWidth
        ]

        return Array(galleryImages.enumerated()).map { index, imageName in
            FindDetailsLearnGalleryCard(
                id: index,
                imageName: imageName,
                width: widths[safe: index] ?? FindDetailsLearnLayout.galleryAlternateLandscapeWidth
            )
        }
    }

    private var featuredStory: StoryCard {
        stories.first(where: { species.storyIDs.contains($0.id) }) ?? stories.first ?? PreviewStories.keystone
    }

    private var recentActivityItems: [FindDetailsLearnRecentItem] {
        [
            .init(
                id: "los-angeles",
                dayLabel: "Today",
                locationText: "Los Angeles,\nCalifornia",
                imageName: "coast-live-oak-gallery-2"
            ),
            .init(
                id: "carmel",
                dayLabel: "Yesterday",
                locationText: "Carmel,\nCalifornia",
                imageName: "coast-live-oak-gallery-1"
            ),
            .init(
                id: "berkeley",
                dayLabel: "Yesterday",
                locationText: "Berkeley,\nCalifornia",
                imageName: "coast-live-oak-gallery-3"
            )
        ]
    }

    private var leaderboardEntries: [FindDetailsLeaderboardEntry] {
        [
            .init(id: "julie-1", rank: "1", name: "Julie Henderson", points: "448", highlighted: false, avatarImageName: "profile-avatar-maya"),
            .init(id: "julie-2", rank: "2", name: "Julie Henderson", points: "448", highlighted: false, avatarImageName: "profile-avatar-maya"),
            .init(id: "julie-3", rank: "3", name: "Julie Henderson", points: "448", highlighted: false, avatarImageName: "profile-avatar-maya"),
            .init(id: "alice", rank: "12", name: "Alice Edwards", points: "12", highlighted: true, avatarImageName: "find-avatar-alice")
        ]
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            GaiaColor.paperWhite50
                .ignoresSafeArea()

            ScrollViewReader { scrollProxy in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .center, spacing: FindDetailsLearnLayout.sectionSpacing) {
                        introSection
                        statsSection
                        gallerySection
                        foundInSection
                        recentActivitySection
                            .id(ScrollMarker.recentActivity)
                        storySection
                        topObserversSection
                        projectSection
                            .id(ScrollMarker.project)
                    }
                    .padding(.top, FindDetailsLearnLayout.contentTopPadding)
                    .padding(.bottom, FindDetailsLearnLayout.footerBottomPadding)
                    .frame(maxWidth: .infinity)
                }
                .task {
                    let target: ScrollMarker?
                    if launchArguments.contains("-gaiaFindDetailsPrototypeLearnDeep") {
                        target = .project
                    } else if launchArguments.contains("-gaiaFindDetailsPrototypeLearnLower") {
                        target = .recentActivity
                    } else {
                        target = nil
                    }

                    guard let target else { return }
                    DispatchQueue.main.async {
                        withAnimation(.none) {
                            scrollProxy.scrollTo(target, anchor: .top)
                        }
                    }
                }
            }

            ToolbarGlassButton(icon: .back, accessibilityLabel: "Back", action: dismiss)
                .padding(.leading, GaiaSpacing.md)
                .safeAreaPadding(.top, GaiaSpacing.sm)
        }
        .ignoresSafeArea(edges: .top)
        .statusBarHidden(true)
        .fullScreenCover(isPresented: $showsExpandedMap) {
            LearnMapExpandedScreen(observations: observations) {
                showsExpandedMap = false
            }
        }
    }

    private var launchArguments: Set<String> {
        Set(ProcessInfo.processInfo.arguments)
    }

    private var introSection: some View {
        VStack(alignment: .center, spacing: FindDetailsLearnLayout.introSpacing) {
            Text(species.scientificName.uppercased())
                .gaiaFont(.scientificLabel)
                .foregroundStyle(GaiaColor.paperWhite50)
                .padding(.horizontal, GaiaSpacing.md)
                .padding(.vertical, GaiaSpacing.cardInset)
                .background(
                    Capsule(style: .continuous)
                        .fill(GaiaColor.oliveGreen300)
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(GaiaColor.borderStrong, lineWidth: 1)
                        )
                )

            Text(species.commonName)
                .gaiaFont(.heroFindExpanded)
                .foregroundStyle(GaiaColor.textPrimary)
                .multilineTextAlignment(.center)

            Text(formattedSummary)
                .gaiaFont(.subheadline)
                .foregroundStyle(FindDetailsLearnLayout.summaryTextColor)
                .multilineTextAlignment(.center)
                .frame(width: FindDetailsLearnLayout.summaryWidth)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, FindDetailsLearnLayout.horizontalInset)
    }

    private var statsSection: some View {
        HStack(spacing: FindDetailsLearnLayout.statsGap) {
            FindDetailsLearnStatCard(label: "Category") {
                GaiaCategoryBadgeIcon(
                    width: FindDetailsLearnLayout.statsCategoryIconWidth,
                    height: FindDetailsLearnLayout.statsCategoryIconHeight
                )
            }

            FindDetailsLearnStatCard(label: "Status") {
                ZStack {
                    Circle()
                        .stroke(
                            GaiaColor.paperWhite50,
                            lineWidth: FindDetailsLearnLayout.statsStatusStrokeWidth
                        )
                    Text(species.status)
                        .font(GaiaTypography.learnStatStatus)
                        .foregroundStyle(GaiaColor.paperWhite50)
                }
                .frame(
                    width: FindDetailsLearnLayout.statsStatusWidth,
                    height: FindDetailsLearnLayout.statsStatusHeight
                )
            }

            FindDetailsLearnStatCard(label: "Finds") {
                Text(species.findCountLabel)
                    .gaiaFont(.statValue)
                    .foregroundStyle(GaiaColor.paperWhite50)
                    .frame(height: FindDetailsLearnLayout.statsContentHeight)
            }
        }
        .padding(.horizontal, FindDetailsLearnLayout.horizontalInset)
    }

    private var gallerySection: some View {
        VStack(spacing: FindDetailsLearnLayout.gallerySectionSpacing) {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: FindDetailsLearnLayout.galleryItemSpacing) {
                    ForEach(galleryCards) { card in
                        galleryCard(card)
                            .id(card.id)
                    }
                }
                .padding(.horizontal, FindDetailsLearnLayout.horizontalInset)
                .scrollTargetLayout()
            }
            .frame(height: FindDetailsLearnLayout.galleryHeight)
            .defaultScrollAnchor(.leading)
            .scrollPosition(id: $selectedGalleryIndex)
            .findDetailsGalleryScrollBehavior()

            HStack(spacing: GaiaSpacing.sm) {
                ForEach(galleryCards) { card in
                    Button {
                        selectGalleryCard(card.id)
                    } label: {
                        Circle()
                            .fill(card.id == currentGalleryIndex ? GaiaColor.olive : GaiaColor.oliveGreen200)
                            .frame(
                                width: FindDetailsLearnLayout.pageDotSize,
                                height: FindDetailsLearnLayout.pageDotSize
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Show gallery image \(card.id + 1)")
                }
            }
            .padding(.horizontal, FindDetailsLearnLayout.galleryPageControlHorizontalPadding)
            .background(
                GaiaMaterialBackground(
                    cornerRadius: FindDetailsLearnLayout.galleryPageControlCornerRadius,
                    interactive: false,
                    showsShadow: false
                )
            )
            .accessibilityElement()
            .accessibilityLabel("Photo gallery")
            .accessibilityValue("Page \(currentGalleryIndex + 1) of \(galleryCards.count)")
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment:
                    selectGalleryCard(min(currentGalleryIndex + 1, galleryCards.count - 1))
                case .decrement:
                    selectGalleryCard(max(currentGalleryIndex - 1, 0))
                @unknown default:
                    break
                }
            }
        }
    }

    private var currentGalleryIndex: Int {
        selectedGalleryIndex ?? galleryCards.first?.id ?? 0
    }

    private func galleryCard(_ card: FindDetailsLearnGalleryCard) -> some View {
        let shape = RoundedRectangle(
            cornerRadius: FindDetailsLearnLayout.galleryCornerRadius,
            style: .continuous
        )

        return GaiaAssetImage(name: card.imageName, contentMode: .fill)
            .frame(width: card.width, height: FindDetailsLearnLayout.galleryHeight)
            .clipShape(shape)
            .overlay(
                shape
                    .stroke(GaiaColor.border, lineWidth: FindDetailsLearnLayout.galleryBorderWidth)
            )
    }

    private func selectGalleryCard(_ id: Int) {
        withAnimation(GaiaMotion.spring) {
            selectedGalleryIndex = id
        }
    }

    private var foundInSection: some View {
        FindDetailsLearnSection(title: "Found in") {
            Button {
                showsExpandedMap = true
            } label: {
                FindDetailsLearnFoundInMapArtwork()
                    .frame(maxWidth: .infinity)
                    .frame(height: FindDetailsLearnLayout.mapHeight)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: FindDetailsLearnLayout.mapCornerRadius,
                            style: .continuous
                        )
                    )
                    .overlay(alignment: .topTrailing) {
                        FindDetailsLearnMapExpandBadge()
                            .padding(FindDetailsLearnLayout.mapExpandInset)
                    }
                    .overlay(
                        RoundedRectangle(
                            cornerRadius: FindDetailsLearnLayout.mapCornerRadius,
                            style: .continuous
                        )
                            .stroke(GaiaColor.border, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityHint("Opens the expanded map")
        }
    }

    private var recentActivitySection: some View {
        FindDetailsLearnSection(
            title: "Recent Activity",
            contentSpacing: FindDetailsLearnLayout.recentActivityHeaderSpacing
        ) {
            VStack(spacing: 0) {
                VStack(spacing: GaiaSpacing.cardInset) {
                    ForEach(recentActivityItems) { item in
                        FindDetailsLearnRecentActivityCard(item: item)
                    }
                }

                FindDetailsLearnTrailingLink(title: "View all")
                    .padding(.top, FindDetailsLearnLayout.recentActivityFooterTopPadding)
            }
        }
    }

    private var storySection: some View {
        FindDetailsLearnSection(title: "Story") {
            StoryPreviewCard(story: featuredStory) {
                onOpenStory(featuredStory)
            }
        }
    }

    private var topObserversSection: some View {
        FindDetailsLearnSection(title: "Top Observers") {
            VStack(spacing: 0) {
                FindDetailsLeaderboardCard(entries: leaderboardEntries)

                FindDetailsLearnTrailingLink(title: "View all")
                    .padding(.top, FindDetailsLearnLayout.leaderboardViewAllTopPadding)
            }
        }
    }

    private var projectSection: some View {
        VStack(alignment: .leading, spacing: FindDetailsLearnLayout.projectCardSpacing) {
            VStack(alignment: .leading, spacing: FindDetailsLearnLayout.projectCardContentSpacing) {
                VStack(alignment: .leading, spacing: FindDetailsLearnLayout.projectCardTitleSpacing) {
                    Text("CITIZEN SCIENCE PROJECT")
                        .gaiaFont(.caption)
                        .foregroundStyle(GaiaColor.paperWhite50)
                        .textCase(.uppercase)

                    Text("Oak Woodland Recovery")
                        .gaiaFont(.displayMedium)
                        .foregroundStyle(GaiaColor.paperWhite50)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text("Help monitor oak tree health across local California woodlands.")
                    .gaiaFont(.caption2)
                    .foregroundStyle(GaiaColor.paperWhite50)
                    .frame(maxWidth: FindDetailsLearnLayout.projectCardSummaryWidth, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button(action: {}) {
                Text("Find out more")
                    .gaiaFont(.body)
                    .foregroundStyle(GaiaColor.broccoliBrown500)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: FindDetailsLearnLayout.projectCardButtonMinHeight)
                    .background(GaiaColor.paperWhite50, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(GaiaSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(projectCardBackground)
        .padding(.horizontal, FindDetailsLearnLayout.horizontalInset)
    }

    private var projectCardBackground: some View {
        let shape = RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)

        return shape
            .fill(GaiaColor.broccoliBrown400)
            .shadow(
                color: GaiaShadow.smallColor,
                radius: GaiaShadow.smallRadius,
                x: 0,
                y: GaiaShadow.smallYOffset
            )
    }

    private var formattedSummary: String {
        let trimmed = species.summary.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = trimmed.first else { return trimmed }
        return first.uppercased() + trimmed.dropFirst()
    }
}

private extension View {
    @ViewBuilder
    func findDetailsGalleryScrollBehavior() -> some View {
        if #available(iOS 26.0, *) {
            scrollTargetBehavior(.viewAligned(limitBehavior: .alwaysByOne, anchor: .leading))
        } else {
            scrollTargetBehavior(.viewAligned)
        }
    }
}

private struct FindDetailsLearnSection<Content: View>: View {
    let title: String
    let contentSpacing: CGFloat
    @ViewBuilder let content: () -> Content

    init(
        title: String,
        contentSpacing: CGFloat = FindDetailsLearnLayout.sectionTitleSpacing,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.contentSpacing = contentSpacing
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: contentSpacing) {
            Text(title)
                .gaiaFont(.titleSans)
                .foregroundStyle(GaiaColor.inkBlack300)
                .padding(.horizontal, FindDetailsLearnLayout.horizontalInset)

            content()
                .padding(.horizontal, FindDetailsLearnLayout.horizontalInset)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct FindDetailsLearnStatCard<Content: View>: View {
    let label: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: FindDetailsLearnLayout.statsCardContentGap) {
            Text(label)
                .gaiaFont(.caption2)
                .foregroundStyle(GaiaColor.paperWhite50)

            content()
                .frame(
                    maxWidth: .infinity,
                    maxHeight: FindDetailsLearnLayout.statsContentHeight,
                    alignment: .center
                )
        }
        .padding(FindDetailsLearnLayout.statsCardInset)
        .frame(width: FindDetailsLearnLayout.statsCardWidth, height: FindDetailsLearnLayout.statsCardHeight)
        .background(
            RoundedRectangle(
                cornerRadius: FindDetailsLearnLayout.statsCardCornerRadius,
                style: .continuous
            )
                .fill(GaiaColor.oliveGreen300)
                .overlay(
                    RoundedRectangle(
                        cornerRadius: FindDetailsLearnLayout.statsCardCornerRadius,
                        style: .continuous
                    )
                        .stroke(
                            Color.black.opacity(0.1),
                            lineWidth: FindDetailsLearnLayout.statsCardBorderWidth
                        )
                )
        )
    }
}

private struct FindDetailsLearnRecentActivityCard: View {
    let item: FindDetailsLearnRecentItem

    var body: some View {
        HStack(spacing: FindDetailsLearnLayout.listContentGap) {
            GaiaAssetImage(name: item.imageName, contentMode: .fill)
                .frame(
                    width: FindDetailsLearnLayout.listImageSize,
                    height: FindDetailsLearnLayout.listImageSize
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: FindDetailsLearnLayout.listImageCornerRadius,
                        style: .continuous
                    )
                )
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: FindDetailsLearnLayout.listTextSpacing) {
                Text(item.dayLabel)
                    .gaiaFont(.footnote)
                    .foregroundStyle(GaiaColor.inkBlack300)
                    .lineLimit(1)

                Text(item.locationText)
                    .gaiaFont(.title1Medium)
                    .foregroundStyle(GaiaColor.olive)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(
                width: FindDetailsLearnLayout.listTextColumnWidth,
                height: FindDetailsLearnLayout.listImageSize,
                alignment: .leading
            )
        }
        .padding(GaiaSpacing.cardInset)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: FindDetailsLearnLayout.listCardHeight, alignment: .leading)
        .background(
            RoundedRectangle(
                cornerRadius: FindDetailsLearnLayout.listCardCornerRadius,
                style: .continuous
            )
            .fill(GaiaColor.paperWhite50)
            .overlay(
                RoundedRectangle(
                    cornerRadius: FindDetailsLearnLayout.listCardCornerRadius,
                    style: .continuous
                )
                .stroke(
                    GaiaColor.borderStrong,
                    lineWidth: FindDetailsLearnLayout.listCardBorderWidth
                )
            )
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        "\(item.dayLabel), \(item.locationText.replacingOccurrences(of: "\n", with: ", "))"
    }
}

private struct FindDetailsLeaderboardCard: View {
    let entries: [FindDetailsLeaderboardEntry]

    var body: some View {
        RoundedRectangle(
            cornerRadius: FindDetailsLearnLayout.leaderboardShellCornerRadius,
            style: .continuous
        )
        .fill(GaiaColor.oliveGreen500)
        .overlay {
            VStack(spacing: -FindDetailsLearnLayout.leaderboardRowOverlap) {
                ForEach(entries) { entry in
                    FindDetailsLeaderboardRow(entry: entry)
                }
            }
            .background(GaiaColor.paperWhite50)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: FindDetailsLearnLayout.leaderboardInnerCornerRadius,
                    style: .continuous
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: FindDetailsLearnLayout.leaderboardInnerCornerRadius,
                    style: .continuous
                )
                    .stroke(
                        GaiaColor.borderStrong,
                        lineWidth: FindDetailsLearnLayout.leaderboardInnerBorderWidth
                    )
            )
        }
        .clipShape(
            RoundedRectangle(
                cornerRadius: FindDetailsLearnLayout.leaderboardShellCornerRadius,
                style: .continuous
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: FindDetailsLearnLayout.leaderboardShellCornerRadius,
                style: .continuous
            )
                .stroke(
                    GaiaColor.borderStrong,
                    lineWidth: FindDetailsLearnLayout.leaderboardShellBorderWidth
                )
        )
    }
}

private struct FindDetailsLeaderboardRow: View {
    let entry: FindDetailsLeaderboardEntry

    var body: some View {
        HStack(spacing: GaiaSpacing.md) {
            HStack(spacing: entry.highlighted
                ? FindDetailsLearnLayout.leaderboardHighlightedRankGap
                : FindDetailsLearnLayout.leaderboardDefaultRankGap
            ) {
                rankBadge

                HStack(spacing: entry.highlighted
                    ? FindDetailsLearnLayout.leaderboardHighlightedProfileGap
                    : FindDetailsLearnLayout.leaderboardDefaultProfileGap
                ) {
                    GaiaProfileAvatar(
                        imageName: entry.avatarImageName,
                        size: entry.highlighted
                            ? FindDetailsLearnLayout.highlightedLeaderboardAvatarSize
                            : FindDetailsLearnLayout.leaderboardAvatarSize,
                        borderWidth: entry.highlighted
                            ? FindDetailsLearnLayout.leaderboardHighlightedAvatarBorderWidth
                            : FindDetailsLearnLayout.leaderboardDefaultAvatarBorderWidth
                    )

                    Text(entry.name)
                        .gaiaFont(.footnote)
                        .foregroundStyle(entry.highlighted ? GaiaColor.paperWhite50 : GaiaColor.olive)
                }
            }

            Spacer(minLength: GaiaSpacing.md)

            HStack(spacing: entry.highlighted
                ? FindDetailsLearnLayout.leaderboardHighlightedPointsGap
                : FindDetailsLearnLayout.leaderboardDefaultPointsGap
            ) {
                Text(entry.points)
                    .font(entry.highlighted ? GaiaTypography.subheadline : GaiaTypography.footnote)
                    .tracking(entry.highlighted ? FindDetailsLearnLayout.leaderboardHighlightedPointsTracking : 0)
                    .foregroundStyle(entry.highlighted ? GaiaColor.paperWhite50 : GaiaColor.oliveGreen300)

                GaiaIcon(
                    kind: .observe(selected: true),
                    size: entry.highlighted
                        ? FindDetailsLearnLayout.highlightedLeaderboardAvatarSize
                        : FindDetailsLearnLayout.leaderboardAvatarSize,
                    tint: entry.highlighted ? GaiaColor.paperWhite50 : GaiaColor.oliveGreen300
                )
            }
        }
        .padding(
            .horizontal,
            entry.highlighted
                ? FindDetailsLearnLayout.leaderboardHighlightedHorizontalInset
                : FindDetailsLearnLayout.leaderboardDefaultHorizontalInset
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: FindDetailsLearnLayout.leaderboardRowHeight, alignment: .leading)
        .background(entry.highlighted ? GaiaColor.oliveGreen300 : GaiaColor.paperWhite50)
        .overlay {
            if !entry.highlighted {
                Rectangle()
                    .stroke(
                        GaiaColor.borderStrong,
                        lineWidth: FindDetailsLearnLayout.leaderboardInnerBorderWidth
                    )
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Rank \(entry.rank), \(entry.name), \(entry.points) finds")
    }

    private var rankBadge: some View {
        let fillColor = entry.highlighted ? GaiaColor.oliveGreen400 : GaiaColor.oliveGreen50
        let strokeColor = entry.highlighted ? GaiaColor.oliveGreen500 : GaiaColor.oliveGreen200
        let textColor = entry.highlighted ? GaiaColor.paperWhite50 : GaiaColor.olive

        return Text(entry.rank)
            .font(GaiaTypography.caption2)
            .tracking(
                entry.highlighted
                    ? FindDetailsLearnLayout.leaderboardHighlightedRankTracking
                    : FindDetailsLearnLayout.leaderboardDefaultRankTracking
            )
            .foregroundStyle(textColor)
            .frame(
                width: FindDetailsLearnLayout.leaderboardRankBadgeSize,
                height: FindDetailsLearnLayout.leaderboardRankBadgeSize
            )
            .background(
                Circle()
                    .fill(fillColor)
                    .overlay(
                        Circle()
                            .stroke(
                                strokeColor,
                                lineWidth: FindDetailsLearnLayout.leaderboardRankStrokeWidth
                            )
                    )
            )
    }
}

private struct FindDetailsLearnMapExpandBadge: View {
    var body: some View {
        GaiaMaterialBackground(cornerRadius: GaiaRadius.full, interactive: false, showsShadow: true)
            .overlay {
                GaiaIcon(
                    kind: .expand,
                    size: FindDetailsLearnLayout.mapExpandIconSize
                )
            }
            .frame(
                width: FindDetailsLearnLayout.mapExpandBadgeSize,
                height: FindDetailsLearnLayout.mapExpandBadgeSize
            )
            .accessibilityHidden(true)
    }
}

private struct FindDetailsLearnTrailingLink: View {
    let title: String

    var body: some View {
        Text(title)
            .gaiaFont(.subheadline)
            .foregroundStyle(GaiaColor.inkBlack300)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

private enum FindDetailsLearnFontResolver {
    static func serif(size: CGFloat, weight: Font.Weight) -> Font {
        if weight == .bold, UIFont(name: "NewSpirit-Bold", size: size) != nil {
            return .custom("NewSpirit-Bold", size: size)
        }
        if UIFont(name: "NewSpirit-Regular", size: size) != nil {
            return .custom("NewSpirit-Regular", size: size)
        }
        return .system(size: size, weight: weight, design: .serif)
    }
}

private struct FindDetailsLearnGalleryCard: Identifiable {
    let id: Int
    let imageName: String
    let width: CGFloat
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
