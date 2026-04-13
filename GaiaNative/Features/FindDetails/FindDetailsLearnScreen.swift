import SwiftUI
import UIKit

private enum FindDetailsLearnLayout {
    static let horizontalInset: CGFloat = 16
    static let sectionSpacing: CGFloat = 32
    static let contentTopPadding: CGFloat = 59
    static let summaryWidth: CGFloat = 326
    static let statsCardWidth: CGFloat = 118
    static let statsCardHeight: CGFloat = 100
    static let statsGap: CGFloat = 8
    static let galleryHeight: CGFloat = 228.479
    static let galleryCornerRadius: CGFloat = 16.336
    static let galleryBorderWidth: CGFloat = 0.828
    static let galleryItemSpacing: CGFloat = 8
    static let galleryLandscapeWidth: CGFloat = 369.209
    static let gallerySquareWidth: CGFloat = 228.479
    static let galleryAlternateLandscapeWidth: CGFloat = 371.278
    static let pageDotSize: CGFloat = 8
    static let mapHeight: CGFloat = 214
    static let mapCornerRadius: CGFloat = 16
    static let listCardCornerRadius: CGFloat = 16
    static let listCardHeight: CGFloat = 112.556
    static let listImageSize: CGFloat = 88.556
    static let leaderboardRowHeight: CGFloat = 52.368
    static let highlightedLeaderboardRowHeight: CGFloat = 56
    static let footerTopPadding: CGFloat = 8
    static let footerBottomPadding: CGFloat = 48
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
            .init(id: "oliver", rank: "1", name: "Oliver King", points: "738", highlighted: false, avatarImageName: "profile-avatar-noah"),
            .init(id: "maya", rank: "2", name: "Maya Chen", points: "641", highlighted: false, avatarImageName: "profile-avatar-noah"),
            .init(id: "jules", rank: "3", name: "Jules Kim", points: "448", highlighted: false, avatarImageName: "profile-avatar-noah"),
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
        VStack(alignment: .center, spacing: GaiaSpacing.md) {
            Text(species.scientificName.uppercased())
                .gaiaFont(.scientificLabel)
                .foregroundStyle(GaiaColor.paperWhite50)
                .padding(.horizontal, GaiaSpacing.md)
                .padding(.vertical, GaiaSpacing.cardInset)
                .background(
                    Capsule(style: .continuous)
                        .fill(GaiaColor.olive)
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(GaiaColor.oliveGreen200, lineWidth: 1)
                        )
                )

            Text(species.commonName)
                .gaiaFont(.heroFindExpanded)
                .foregroundStyle(GaiaColor.textPrimary)
                .multilineTextAlignment(.center)

            Text(formattedSummary)
                .gaiaFont(.subheadline)
                .foregroundStyle(GaiaColor.paperWhite600)
                .multilineTextAlignment(.center)
                .frame(width: FindDetailsLearnLayout.summaryWidth)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, FindDetailsLearnLayout.horizontalInset)
    }

    private var statsSection: some View {
        HStack(spacing: FindDetailsLearnLayout.statsGap) {
            FindDetailsLearnStatCard(label: "Category") {
                GaiaCategoryBadgeIcon()
            }

            FindDetailsLearnStatCard(label: "Status") {
                ZStack {
                    Circle()
                        .stroke(GaiaColor.paperWhite50, lineWidth: 3.265)
                    Text(species.status)
                        .font(FindDetailsLearnFontResolver.serif(size: 21.765, weight: .bold))
                        .foregroundStyle(GaiaColor.paperWhite50)
                }
                .frame(width: 54.412, height: 54.412)
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
        VStack(spacing: GaiaSpacing.sm) {
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
                    .stroke(GaiaColor.oliveGreen200, lineWidth: FindDetailsLearnLayout.galleryBorderWidth)
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
                            .padding(11.222)
                    }
                    .overlay(
                        RoundedRectangle(
                            cornerRadius: FindDetailsLearnLayout.mapCornerRadius,
                            style: .continuous
                        )
                            .stroke(GaiaColor.oliveGreen200, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private var recentActivitySection: some View {
        FindDetailsLearnSection(title: "Recent Activity") {
            VStack(spacing: GaiaSpacing.cardInset) {
                ForEach(recentActivityItems) { item in
                    FindDetailsLearnRecentActivityCard(item: item)
                }

                FindDetailsLearnTrailingLink(title: "See all")
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

                FindDetailsLearnTrailingLink(title: "See all")
                    .padding(.top, FindDetailsLearnLayout.footerTopPadding)
            }
        }
    }

    private var projectSection: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.md) {
            Text("CITIZEN SCIENCE PROJECT")
                .gaiaFont(.caption)
                .foregroundStyle(GaiaColor.paperWhite50)
                .textCase(.uppercase)

            VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                Text("Oak Woodland\nRecovery")
                    .gaiaFont(.displayMedium)
                    .foregroundStyle(GaiaColor.paperWhite50)

                Text("Help monitor oak tree health across local California woodlands.")
                    .gaiaFont(.caption2)
                    .foregroundStyle(GaiaColor.paperWhite50)
            }

            Button(action: {}) {
                Text("Find out more")
                    .gaiaFont(.body)
                    .foregroundStyle(GaiaColor.broccoliBrown500)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(GaiaColor.broccoliBrown50, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(GaiaSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                .fill(GaiaColor.broccoliBrown500)
        )
        .padding(.horizontal, FindDetailsLearnLayout.horizontalInset)
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
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.cardInset) {
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
        VStack(spacing: GaiaSpacing.cardInset) {
            Text(label)
                .gaiaFont(.caption2)
                .foregroundStyle(GaiaColor.paperWhite50)

            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .padding(GaiaSpacing.cardInset)
        .frame(width: FindDetailsLearnLayout.statsCardWidth, height: FindDetailsLearnLayout.statsCardHeight)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                .fill(GaiaColor.olive)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                        .stroke(GaiaColor.oliveGreen200, lineWidth: 1)
                )
        )
    }
}

private struct FindDetailsLearnRecentActivityCard: View {
    let item: FindDetailsLearnRecentItem

    var body: some View {
        HStack(spacing: GaiaSpacing.cardInset) {
            GaiaAssetImage(name: item.imageName, contentMode: .fill)
                .frame(
                    width: FindDetailsLearnLayout.listImageSize,
                    height: FindDetailsLearnLayout.listImageSize
                )
                .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))

            VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                Text(item.dayLabel)
                    .gaiaFont(.footnote)
                    .foregroundStyle(GaiaColor.inkBlack300)

                Text(item.locationText)
                    .gaiaFont(.title1Medium)
                    .foregroundStyle(GaiaColor.olive)
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
                    .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
            )
        )
    }
}

private struct FindDetailsLeaderboardCard: View {
    let entries: [FindDetailsLeaderboardEntry]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(entries) { entry in
                FindDetailsLeaderboardRow(entry: entry)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                .stroke(GaiaColor.oliveGreen200, lineWidth: 0.5)
        )
    }
}

private struct FindDetailsLeaderboardRow: View {
    let entry: FindDetailsLeaderboardEntry

    var body: some View {
        HStack(spacing: GaiaSpacing.md) {
            HStack(spacing: GaiaSpacing.md) {
                Text(entry.rank)
                    .font(FindDetailsLearnFontResolver.serif(size: 26.184, weight: .regular))
                    .foregroundStyle(entry.highlighted ? GaiaColor.paperWhite50 : GaiaColor.olive)
                    .frame(width: entry.rank == "12" ? 26 : 20, alignment: .leading)

                HStack(spacing: entry.highlighted ? GaiaSpacing.sm : 7.481) {
                    GaiaProfileAvatar(
                        imageName: entry.avatarImageName,
                        size: entry.highlighted ? 32 : 29.924,
                        borderWidth: entry.highlighted ? 0.333 : 0.312
                    )

                    Text(entry.name)
                        .font(
                            entry.highlighted
                                ? GaiaTypography.callout
                                : GaiaTypography.footnote
                        )
                        .foregroundStyle(entry.highlighted ? GaiaColor.paperWhite50 : GaiaColor.olive)
                }
            }

            Spacer(minLength: GaiaSpacing.md)

            HStack(spacing: entry.highlighted ? GaiaSpacing.xs : 3.741) {
                Text(entry.points)
                    .font(entry.highlighted ? GaiaTypography.callout : GaiaTypography.footnote)
                    .foregroundStyle(entry.highlighted ? GaiaColor.paperWhite50 : GaiaColor.olive)

                GaiaIcon(kind: .observe(selected: true), size: entry.highlighted ? 32 : 29.924, tint: entry.highlighted ? GaiaColor.paperWhite50 : GaiaColor.olive)
            }
        }
        .padding(.horizontal, entry.highlighted ? GaiaSpacing.md : 14.962)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(
            height: entry.highlighted
                ? FindDetailsLearnLayout.highlightedLeaderboardRowHeight
                : FindDetailsLearnLayout.leaderboardRowHeight,
            alignment: .leading
        )
        .background(entry.highlighted ? GaiaColor.oliveGreen300 : GaiaColor.paperWhite50)
        .overlay(alignment: .top) {
            if !entry.highlighted {
                Rectangle()
                    .fill(GaiaColor.oliveGreen200)
                    .frame(height: 0.5)
            }
        }
    }
}

private struct FindDetailsLearnTrailingLink: View {
    let title: String

    var body: some View {
        HStack {
            Spacer()
            Text(title)
                .gaiaFont(.subheadline)
                .foregroundStyle(GaiaColor.olive)
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
