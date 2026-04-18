import SwiftUI
import UIKit

// figma: https://www.figma.com/design/X0NcuRE0WKmsqR36cvlcij/Write-Test-Pro?node-id=22-1599&m=dev

private enum FindDetailsLearnLayout {
    static let horizontalInset: CGFloat = 16
    static let sectionSpacing: CGFloat = 32
    static let introSpacing: CGFloat = 20
    static let contentTopPadding: CGFloat = 59
    static let summaryWidth: CGFloat = 326

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
    static let statsStatusFontSize: CGFloat = 21.923
    static let statsGap: CGFloat = 8

    static let galleryHeight: CGFloat = 240
    static let galleryCornerRadius: CGFloat = 16.371
    static let galleryBorderWidth: CGFloat = 0.83
    static let galleryItemSpacing: CGFloat = 8
    static let gallerySectionSpacing: CGFloat = 12
    static let galleryPageControlHorizontalPadding: CGFloat = 24
    static let galleryPageControlCornerRadius: CGFloat = 50
    static let galleryLandscapeWidth: CGFloat = 370
    static let gallerySquareWidth: CGFloat = 239.918
    static let galleryAlternateLandscapeWidth: CGFloat = 389.867
    static let galleryTrailingLandscapeWidth: CGFloat = 370
    static let pageDotSize: CGFloat = 8

    static let mapHeight: CGFloat = 214
    static let mapCornerRadius: CGFloat = 16
    static let mapExpandInset: CGFloat = 11.222

    static let listCardCornerRadius: CGFloat = 16
    static let listCardHeight: CGFloat = 112.556
    static let listImageSize: CGFloat = 88.556
    static let listContentGap: CGFloat = 14.962
    static let listTextSpacing: CGFloat = 12
    static let listCardBorderWidth: CGFloat = 1
    static let recentActivityHeaderSpacing: CGFloat = 16

    static let leaderboardShellCornerRadius: CGFloat = 16
    static let leaderboardShellBorderWidth: CGFloat = 1
    static let leaderboardInnerCornerRadius: CGFloat = 15.044
    static let leaderboardInnerBorderWidth: CGFloat = 0.94
    static let leaderboardRowHeight: CGFloat = 56
    static let leaderboardRowOverlap: CGFloat = 0.901
    static let leaderboardRankBadgeSize: CGFloat = 20.09
    static let leaderboardAvatarSize: CGFloat = 28.842
    static let leaderboardHighlightedAvatarSize: CGFloat = 30.843
    static let leaderboardDefaultHorizontalInset: CGFloat = 16
    static let leaderboardHighlightedHorizontalInset: CGFloat = 15.422
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

    static let footerTopPadding: CGFloat = 8
    static let footerBottomPadding: CGFloat = 48

    static let projectCardSpacing: CGFloat = 23.799
    static let projectCardContentSpacing: CGFloat = 15.549
    static let projectCardTitleSpacing: CGFloat = 11.998
    static let projectCardSummaryWidth: CGFloat = 235.772
    static let projectCardCornerRadius: CGFloat = 15.549
    static let projectCardButtonMinHeight: CGFloat = 49.99
    static let projectCardShadowRadius: CGFloat = 19.996
    static let projectCardShadowYOffset: CGFloat = 4
}

private enum FindDetailsLearnTheme {
    static let primaryOlive300 = Color(.sRGB, red: 147 / 255, green: 164 / 255, blue: 129 / 255, opacity: 1)
    static let primaryOlive400 = Color(.sRGB, red: 120 / 255, green: 142 / 255, blue: 97 / 255, opacity: 1)
    static let primaryOlive500 = Color(.sRGB, red: 107 / 255, green: 131 / 255, blue: 82 / 255, opacity: 1)
    static let borderStrong = Color(.sRGB, red: 173 / 255, green: 186 / 255, blue: 159 / 255, opacity: 1)
    static let overlayDark = Color.black.opacity(0.1)
    static let summaryText = GaiaColor.bgSubtle
    static let projectShadow = Color(.sRGB, red: 128 / 255, green: 105 / 255, blue: 38 / 255, opacity: 0.09)
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
        let images = species.galleryAssetNames
        return images.isEmpty
            ? [
                "coast-live-oak-gallery-1",
                "coast-live-oak-gallery-2",
                "coast-live-oak-gallery-3",
                "coast-live-oak-gallery-4"
            ]
            : images
    }

    private var galleryCards: [FindDetailsLearnGalleryCard] {
        let widths = [
            FindDetailsLearnLayout.galleryLandscapeWidth,
            FindDetailsLearnLayout.gallerySquareWidth,
            FindDetailsLearnLayout.galleryAlternateLandscapeWidth,
            FindDetailsLearnLayout.galleryTrailingLandscapeWidth
        ]

        return Array(galleryImages.enumerated()).map { index, imageName in
            FindDetailsLearnGalleryCard(
                id: index,
                imageName: imageName,
                width: widths[safe: index] ?? FindDetailsLearnLayout.galleryTrailingLandscapeWidth
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
                .safeAreaPadding(.top, 8)
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
                        .fill(FindDetailsLearnTheme.primaryOlive300)
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(FindDetailsLearnTheme.borderStrong, lineWidth: 1)
                        )
                )

            Text(species.commonName)
                .gaiaFont(.heroFindExpanded)
                .foregroundStyle(GaiaColor.textPrimary)
                .multilineTextAlignment(.center)

            Text(formattedSummary)
                .gaiaFont(.subheadline)
                .foregroundStyle(FindDetailsLearnTheme.summaryText)
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
                        .stroke(GaiaColor.paperWhite50, lineWidth: FindDetailsLearnLayout.statsStatusStrokeWidth)
                    Text(species.status)
                        .font(FindDetailsLearnFontResolver.serif(size: FindDetailsLearnLayout.statsStatusFontSize, weight: .bold))
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
                        withAnimation(GaiaMotion.spring) {
                            selectedGalleryIndex = card.id
                        }
                    } label: {
                        Circle()
                            .fill(card.id == currentGalleryIndex ? FindDetailsLearnTheme.primaryOlive500 : FindDetailsLearnTheme.borderStrong)
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
                    .stroke(FindDetailsLearnTheme.borderStrong, lineWidth: FindDetailsLearnLayout.galleryBorderWidth)
            )
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
                        ExpandMapButton(action: { showsExpandedMap = true })
                            .padding(FindDetailsLearnLayout.mapExpandInset)
                    }
                    .overlay(
                        RoundedRectangle(
                            cornerRadius: FindDetailsLearnLayout.mapCornerRadius,
                            style: .continuous
                        )
                        .stroke(FindDetailsLearnTheme.borderStrong, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private var recentActivitySection: some View {
        FindDetailsLearnSection(
            title: "Recent Activity",
            contentSpacing: FindDetailsLearnLayout.recentActivityHeaderSpacing
        ) {
            VStack(spacing: GaiaSpacing.cardInset) {
                ForEach(recentActivityItems) { item in
                    FindDetailsLearnRecentActivityCard(item: item)
                }

                FindDetailsLearnTrailingLink(title: "View all")
                    .padding(.top, FindDetailsLearnLayout.footerTopPadding)
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
            VStack(spacing: GaiaSpacing.cardInset) {
                FindDetailsLeaderboardCard(entries: leaderboardEntries)

                FindDetailsLearnTrailingLink(title: "View all")
                    .padding(.top, FindDetailsLearnLayout.footerTopPadding)
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

                    Text("Oak Woodland\nRecovery")
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
                    .font(FindDetailsLearnFontResolver.sans(size: 16.99, weight: .regular))
                    .foregroundStyle(GaiaColor.broccoliBrown500)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: FindDetailsLearnLayout.projectCardButtonMinHeight)
                    .background(GaiaColor.paperWhite50, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(15.997)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(projectCardBackground)
        .padding(.horizontal, FindDetailsLearnLayout.horizontalInset)
    }

    private var projectCardBackground: some View {
        RoundedRectangle(cornerRadius: FindDetailsLearnLayout.projectCardCornerRadius, style: .continuous)
            .fill(GaiaColor.broccoliBrown400)
            .shadow(
                color: FindDetailsLearnTheme.projectShadow,
                radius: FindDetailsLearnLayout.projectCardShadowRadius,
                x: 0,
                y: FindDetailsLearnLayout.projectCardShadowYOffset
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
        contentSpacing: CGFloat = GaiaSpacing.cardInset,
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
                .font(FindDetailsLearnFontResolver.sans(size: 12.087, weight: .regular))
                .foregroundStyle(GaiaColor.paperWhite50)

            content()
                .frame(maxWidth: .infinity, maxHeight: FindDetailsLearnLayout.statsContentHeight, alignment: .center)
        }
        .padding(FindDetailsLearnLayout.statsCardInset)
        .frame(width: FindDetailsLearnLayout.statsCardWidth, height: FindDetailsLearnLayout.statsCardHeight)
        .background(
            RoundedRectangle(cornerRadius: FindDetailsLearnLayout.statsCardCornerRadius, style: .continuous)
                .fill(FindDetailsLearnTheme.primaryOlive300)
                .overlay(
                    RoundedRectangle(cornerRadius: FindDetailsLearnLayout.statsCardCornerRadius, style: .continuous)
                        .stroke(FindDetailsLearnTheme.overlayDark, lineWidth: FindDetailsLearnLayout.statsCardBorderWidth)
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
                .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.thumbnail, style: .continuous))

            VStack(alignment: .leading, spacing: FindDetailsLearnLayout.listTextSpacing) {
                Text(item.dayLabel)
                    .gaiaFont(.footnote)
                    .foregroundStyle(GaiaColor.inkBlack300)

                Text(item.locationText)
                    .gaiaFont(.title1Medium)
                    .foregroundStyle(FindDetailsLearnTheme.primaryOlive500)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
                .stroke(FindDetailsLearnTheme.borderStrong, lineWidth: FindDetailsLearnLayout.listCardBorderWidth)
            )
        )
    }
}

private struct FindDetailsLeaderboardCard: View {
    let entries: [FindDetailsLeaderboardEntry]

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: FindDetailsLearnLayout.leaderboardShellCornerRadius, style: .continuous)
                .fill(FindDetailsLearnTheme.primaryOlive500)

            VStack(spacing: -FindDetailsLearnLayout.leaderboardRowOverlap) {
                ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                    FindDetailsLeaderboardRow(
                        entry: entry,
                        showsDivider: index > 0
                    )
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
                .stroke(FindDetailsLearnTheme.borderStrong, lineWidth: FindDetailsLearnLayout.leaderboardInnerBorderWidth)
            )
            .padding(FindDetailsLearnLayout.leaderboardShellBorderWidth)
        }
        .overlay(
            RoundedRectangle(cornerRadius: FindDetailsLearnLayout.leaderboardShellCornerRadius, style: .continuous)
                .stroke(FindDetailsLearnTheme.borderStrong, lineWidth: FindDetailsLearnLayout.leaderboardShellBorderWidth)
        )
    }
}

private struct FindDetailsLeaderboardRow: View {
    let entry: FindDetailsLeaderboardEntry
    let showsDivider: Bool

    var body: some View {
        HStack(spacing: GaiaSpacing.md) {
            HStack(spacing: entry.highlighted ? FindDetailsLearnLayout.leaderboardHighlightedRankGap : FindDetailsLearnLayout.leaderboardDefaultRankGap) {
                rankBadge

                HStack(spacing: entry.highlighted ? FindDetailsLearnLayout.leaderboardHighlightedProfileGap : FindDetailsLearnLayout.leaderboardDefaultProfileGap) {
                    GaiaProfileAvatar(
                        imageName: entry.avatarImageName,
                        size: entry.highlighted ? FindDetailsLearnLayout.leaderboardHighlightedAvatarSize : FindDetailsLearnLayout.leaderboardAvatarSize,
                        borderWidth: entry.highlighted ? FindDetailsLearnLayout.leaderboardHighlightedAvatarBorderWidth : FindDetailsLearnLayout.leaderboardDefaultAvatarBorderWidth
                    )

                    Text(entry.name)
                        .font(FindDetailsLearnFontResolver.sans(size: 13.52, weight: .regular))
                        .foregroundStyle(entry.highlighted ? GaiaColor.paperWhite50 : FindDetailsLearnTheme.primaryOlive500)
                }
            }

            Spacer(minLength: GaiaSpacing.md)

            HStack(spacing: entry.highlighted ? FindDetailsLearnLayout.leaderboardHighlightedPointsGap : FindDetailsLearnLayout.leaderboardDefaultPointsGap) {
                Text(entry.points)
                    .font(
                        FindDetailsLearnFontResolver.sans(
                            size: entry.highlighted ? 15.422 : 13.52,
                            weight: .regular
                        )
                    )
                    .tracking(entry.highlighted ? FindDetailsLearnLayout.leaderboardHighlightedPointsTracking : 0)
                    .foregroundStyle(entry.highlighted ? GaiaColor.paperWhite50 : FindDetailsLearnTheme.primaryOlive300)

                GaiaIcon(
                    kind: .observe(selected: true),
                    size: entry.highlighted ? FindDetailsLearnLayout.leaderboardHighlightedAvatarSize : FindDetailsLearnLayout.leaderboardAvatarSize,
                    tint: entry.highlighted ? GaiaColor.paperWhite50 : FindDetailsLearnTheme.primaryOlive300
                )
            }
        }
        .padding(.horizontal, entry.highlighted ? FindDetailsLearnLayout.leaderboardHighlightedHorizontalInset : FindDetailsLearnLayout.leaderboardDefaultHorizontalInset)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: FindDetailsLearnLayout.leaderboardRowHeight, alignment: .leading)
        .background(entry.highlighted ? FindDetailsLearnTheme.primaryOlive300 : GaiaColor.paperWhite50)
        .overlay(alignment: .top) {
            if showsDivider {
                Rectangle()
                    .fill(FindDetailsLearnTheme.borderStrong)
                    .frame(height: 0.5)
            }
        }
    }

    private var rankBadge: some View {
        let fillColor = entry.highlighted ? FindDetailsLearnTheme.primaryOlive400 : GaiaColor.oliveGreen50
        let strokeColor = entry.highlighted ? FindDetailsLearnTheme.primaryOlive500 : FindDetailsLearnTheme.borderStrong
        let textColor = entry.highlighted ? GaiaColor.oliveGreen50 : FindDetailsLearnTheme.primaryOlive500
        let tracking = entry.highlighted
            ? FindDetailsLearnLayout.leaderboardHighlightedRankTracking
            : FindDetailsLearnLayout.leaderboardDefaultRankTracking

        return Text(entry.rank)
            .font(FindDetailsLearnFontResolver.sans(size: 12.689, weight: .regular))
            .tracking(tracking)
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
                            .stroke(strokeColor, lineWidth: FindDetailsLearnLayout.leaderboardRankStrokeWidth)
                    )
            )
    }
}

private struct FindDetailsLearnTrailingLink: View {
    let title: String

    var body: some View {
        HStack {
            Spacer(minLength: 0)

            Text(title)
                .gaiaFont(.subheadline)
                .foregroundStyle(GaiaColor.inkBlack300)
        }
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

    static func sans(size: CGFloat, weight: Font.Weight) -> Font {
        let candidates = [
            "neue-haas-unica",
            "Neue Haas Unica W1G",
            "Neue Haas Unica",
            "NeueHaasUnica",
            "NeueHaasUnica-Regular",
            "NeueHaasUnica-Medium",
            "NeueHaasUnica-Bold"
        ]

        if let name = candidates.first(where: { UIFont(name: $0, size: size) != nil }) {
            return .custom(name, size: size)
        }

        return .system(size: size, weight: weight, design: .default)
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
