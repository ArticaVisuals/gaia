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
    static let pageDotSize: CGFloat = 8
    static let mapHeight: CGFloat = 214
    static let mapCornerRadius: CGFloat = 16
    static let listCardCornerRadius: CGFloat = 16
    static let listCardHeight: CGFloat = 112.556
    static let listImageSize: CGFloat = 88.556
    static let leaderboardRowHeight: CGFloat = 52.368
    static let highlightedLeaderboardRowHeight: CGFloat = 56
    static let footerTopPadding: CGFloat = 12
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
}

struct FindDetailsLearnScreen: View {
    let species: Species
    let observations: [Observation]
    let stories: [StoryCard]
    let dismiss: () -> Void
    let onOpenStory: (StoryCard) -> Void

    @State private var selectedGalleryIndex = 0
    @State private var showsExpandedMap = false

    private var galleryImages: [String] {
        let images = Array(species.galleryAssetNames.dropFirst())
        return images.isEmpty ? ["coast-live-oak-gallery-1"] : images
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
            .init(id: "oliver", rank: "1", name: "Oliver King", points: "738", highlighted: false),
            .init(id: "maya", rank: "2", name: "Maya Chen", points: "641", highlighted: false),
            .init(id: "jules", rank: "3", name: "Jules Kim", points: "448", highlighted: false),
            .init(id: "alice", rank: "12", name: "Alice Edwards", points: "12", highlighted: true)
        ]
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            GaiaColor.paperWhite50
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: FindDetailsLearnLayout.sectionSpacing) {
                    introSection
                    statsSection
                    gallerySection
                    foundInSection
                    recentActivitySection
                    storySection
                    topObserversSection
                    projectSection
                }
                .padding(.top, FindDetailsLearnLayout.contentTopPadding)
                .padding(.bottom, FindDetailsLearnLayout.footerBottomPadding)
                .frame(maxWidth: .infinity)
            }

            ToolbarGlassButton(icon: .back, accessibilityLabel: "Back", action: dismiss)
                .padding(.leading, GaiaSpacing.md)
                .safeAreaPadding(.top, 8)
        }
        .ignoresSafeArea(edges: .top)
        .fullScreenCover(isPresented: $showsExpandedMap) {
            LearnMapExpandedScreen(observations: observations) {
                showsExpandedMap = false
            }
        }
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
                GaiaAssetImage(name: "learn-category-badge", contentMode: .fit)
                    .frame(width: 53.324, height: 53.333)
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
            TabView(selection: $selectedGalleryIndex) {
                ForEach(Array(galleryImages.enumerated()), id: \.offset) { index, imageName in
                    GaiaAssetImage(name: imageName, contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: FindDetailsLearnLayout.galleryCornerRadius,
                                style: .continuous
                            )
                        )
                        .overlay(
                            RoundedRectangle(
                                cornerRadius: FindDetailsLearnLayout.galleryCornerRadius,
                                style: .continuous
                            )
                                .stroke(GaiaColor.oliveGreen200, lineWidth: 0.828)
                        )
                        .padding(.horizontal, FindDetailsLearnLayout.horizontalInset)
                        .tag(index)
                }
            }
            .frame(height: FindDetailsLearnLayout.galleryHeight)
            .tabViewStyle(.page(indexDisplayMode: .never))

            HStack(spacing: GaiaSpacing.sm) {
                ForEach(galleryImages.indices, id: \.self) { index in
                    Circle()
                        .fill(index == selectedGalleryIndex ? GaiaColor.olive : GaiaColor.oliveGreen200)
                        .frame(
                            width: FindDetailsLearnLayout.pageDotSize,
                            height: FindDetailsLearnLayout.pageDotSize
                        )
                }
            }
        }
    }

    private var foundInSection: some View {
        FindDetailsLearnSection(title: "Found in") {
            Button {
                showsExpandedMap = true
            } label: {
                GaiaAssetImage(name: "observe-map-preview", contentMode: .fill)
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
                .shadow(
                    color: GaiaShadow.cardColor,
                    radius: GaiaShadow.cardRadius,
                    x: 0,
                    y: GaiaShadow.mdYOffset
                )
        )
        .padding(.horizontal, FindDetailsLearnLayout.horizontalInset)
    }

    private var formattedSummary: String {
        let trimmed = species.summary.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = trimmed.first else { return trimmed }
        return first.uppercased() + trimmed.dropFirst()
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
                    .gaiaFont(.caption)
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
                        imageName: "find-avatar-alice",
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
