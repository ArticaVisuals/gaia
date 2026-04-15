import SwiftUI

private enum FindTabLayout {
    static let sectionSpacing: CGFloat = GaiaSpacing.lg
    static let cardSpacing: CGFloat = GaiaSpacing.sm
    static let mapHeight: CGFloat = 181
    static let mapCardInset: CGFloat = GaiaSpacing.cardInset
    static let mapProfileAvatarSize: CGFloat = GaiaSpacing.iconXl
    static let photoHeight: CGFloat = 134
    static let photoCornerRadius: CGFloat = GaiaRadius.md
    static let footerSpacing: CGFloat = GaiaSpacing.cardInset
    static let projectCardHeight: CGFloat = 81
    static let projectImageWidth: CGFloat = 82
    static let projectImageHeight: CGFloat = 57
}

struct FindTabView: View {
    let collapseProgress: CGFloat
    let usesCollapsedContentLayout: Bool
    let photoAssetNames: [String]
    let mapObservation: Observation
    let onExpandMap: () -> Void
    let onOpenProject: (ProjectSelection) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: FindTabLayout.sectionSpacing) {
                section(title: "Found in") {
                    FindMapPreviewCard(
                        observation: mapObservation,
                        collapseProgress: collapseProgress,
                        onExpandMap: onExpandMap
                    )
                }

                section(title: "Photos") {
                    FindPhotoRail(imageNames: photoAssetNames)
                }

                section(title: "Condition") {
                    FindConditionCardsRow()
                }

                section(title: "Data Quality") {
                    VStack(alignment: .leading, spacing: FindTabLayout.footerSpacing) {
                        FindDataQualityCard()
                        FindSectionFooterLink(title: "Learn more")
                    }
                }

                section(title: "Participating Projects") {
                    VStack(alignment: .leading, spacing: FindTabLayout.footerSpacing) {
                        FindProjectListCard(
                            title: "Creek Recovery",
                            subtitle: "Ends tomorrow",
                            location: "Altadena, CA",
                            imageName: "find-project-creek"
                        ) {
                            onOpenProject(
                                ProjectSelection(
                                    id: "project-creek",
                                    title: "Creek Recovery",
                                    tag: "Wetland",
                                    countLabel: "12",
                                    imageName: "find-project-creek"
                                )
                            )
                        }

                        FindProjectListCard(
                            title: "Pollinator Corridor",
                            subtitle: "Ends in 10 days",
                            location: "Pasadena, CA",
                            imageName: "find-project-pollinator"
                        ) {
                            onOpenProject(
                                ProjectSelection(
                                    id: "project-pollinator",
                                    title: "Pollinator Corridor",
                                    tag: "Garden",
                                    countLabel: "9",
                                    imageName: "find-project-pollinator"
                                )
                            )
                        }

                        FindSectionFooterLink(title: "Show all")
                    }
                }
            }
        }
        .padding(.horizontal, GaiaSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(GaiaColor.paperWhite50)
    }

    private func section<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.cardInset) {
            Text(title)
                .gaiaFont(.titleSans)
                .foregroundStyle(GaiaColor.inkBlack300)

            content()
        }
    }
}

enum FindConditionLayout {
    static let cardSpacing: CGFloat = GaiaSpacing.sm
    static let cardInset: CGFloat = GaiaSpacing.cardInset
    static let cardHeight: CGFloat = 206
    static let imageHeight: CGFloat = 126
    static let contentSpacing: CGFloat = GaiaSpacing.sm
    static let cardCornerRadius: CGFloat = GaiaRadius.lg
    static let imageCornerRadius: CGFloat = GaiaRadius.md
    static let accessorySize: CGFloat = 20
    static let weatherBackgroundWidthScale: CGFloat = 1.7865
    static let weatherBackgroundHeightScale: CGFloat = 2.2261
    static let weatherBackgroundLeftOffset: CGFloat = 0.0828
    static let weatherBackgroundTopOffset: CGFloat = 0.4235
    static let biomeVerticalScale: CGFloat = 1.246
}

struct FindConditionCardsRow: View {
    var body: some View {
        HStack(alignment: .top, spacing: FindConditionLayout.cardSpacing) {
            FindConditionCard(
                label: "Biome",
                title: "Riparian Edge",
                subtitle: "Perfumo Canyon"
            ) {
                FindBiomeConditionArtwork()
            }

            FindConditionCard(
                label: "Weather",
                title: "Partly Cloudy",
                subtitle: "July 10, 2025, 10:19 AM"
            ) {
                FindWeatherConditionArtwork()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct FindConditionCard<Artwork: View>: View {
    let label: String
    let title: String
    let subtitle: String
    @ViewBuilder let artwork: () -> Artwork

    private var imageShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: FindConditionLayout.imageCornerRadius, style: .continuous)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: FindConditionLayout.contentSpacing) {
            artwork()
                .frame(maxWidth: .infinity)
                .frame(height: FindConditionLayout.imageHeight)
                .clipShape(imageShape)
                .overlay(
                    imageShape
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
                )

            Text(label)
                .gaiaFont(.caption)
                .foregroundStyle(GaiaColor.broccoliBrown500)
                .lineLimit(1)

            HStack(alignment: .top, spacing: GaiaSpacing.sm) {
                VStack(alignment: .leading, spacing: FindConditionLayout.contentSpacing) {
                    Text(title)
                        .gaiaFont(.body)
                        .foregroundStyle(GaiaColor.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)

                    Text(subtitle)
                        .gaiaFont(.caption)
                        .foregroundStyle(GaiaColor.inkBlack200)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                GaiaIcon(kind: .circleArrowRight, size: FindConditionLayout.accessorySize)
                    .frame(
                        width: FindConditionLayout.accessorySize,
                        height: FindConditionLayout.accessorySize
                    )
                    .padding(.top, GaiaSpacing.xxs)
            }
        }
        .padding(FindConditionLayout.cardInset)
        .frame(maxWidth: .infinity, minHeight: FindConditionLayout.cardHeight, maxHeight: FindConditionLayout.cardHeight, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: FindConditionLayout.cardCornerRadius, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: FindConditionLayout.cardCornerRadius, style: .continuous)
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
                )
        )
    }
}

private struct FindBiomeConditionArtwork: View {
    var body: some View {
        GaiaAssetImage(name: "find-biome-riparian", contentMode: .fill)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .scaleEffect(x: 1, y: FindConditionLayout.biomeVerticalScale, anchor: .top)
            .clipped()
    }
}

private struct FindWeatherConditionArtwork: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                weatherBackground(in: proxy.size)

                Text("54º")
                    .gaiaFont(.weatherValue)
                    .foregroundStyle(GaiaColor.paperWhite50)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.leading, GaiaSpacing.cardInset)
                    .offset(y: -6)
                    .accessibilityHidden(true)
            }
        }
        .clipped()
    }

    @ViewBuilder
    private func weatherBackground(in size: CGSize) -> some View {
        if let image = AssetCatalog.uiImage(named: "find-weather-bg") {
            Image(uiImage: image)
                .resizable()
                .interpolation(.high)
                .frame(
                    width: size.width * FindConditionLayout.weatherBackgroundWidthScale,
                    height: size.height * FindConditionLayout.weatherBackgroundHeightScale
                )
                .offset(
                    x: -(size.width * FindConditionLayout.weatherBackgroundLeftOffset),
                    y: -(size.height * FindConditionLayout.weatherBackgroundTopOffset)
                )
        } else {
            GaiaAssetImage(name: "find-weather-bg", contentMode: .fill)
                .frame(
                    width: size.width * FindConditionLayout.weatherBackgroundWidthScale,
                    height: size.height * FindConditionLayout.weatherBackgroundHeightScale
                )
                .offset(
                    x: -(size.width * FindConditionLayout.weatherBackgroundLeftOffset),
                    y: -(size.height * FindConditionLayout.weatherBackgroundTopOffset)
                )
        }
    }
}

private struct FindSectionFooterLink: View {
    let title: String

    var body: some View {
        Text(title)
            .gaiaFont(.subheadline)
            .foregroundStyle(GaiaColor.olive)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

private struct FindPhotoRail: View {
    let imageNames: [String]

    private let widths: [CGFloat] = [223, 138, 104]

    private var displayedImages: [String] {
        guard !imageNames.isEmpty else {
            return Array(repeating: "coast-live-oak-gallery-1", count: widths.count)
        }

        return widths.indices.map { imageNames[$0 % imageNames.count] }
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: FindTabLayout.cardSpacing) {
                ForEach(Array(displayedImages.enumerated()), id: \.offset) { index, imageName in
                    GaiaAssetImage(name: imageName)
                        .frame(width: widths[index], height: FindTabLayout.photoHeight)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: FindTabLayout.photoCornerRadius,
                                style: .continuous
                            )
                        )
                        .overlay(
                            RoundedRectangle(
                                cornerRadius: FindTabLayout.photoCornerRadius,
                                style: .continuous
                            )
                                .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
                        )
                }
            }
            .scrollTargetLayout()
        }
        .frame(height: FindTabLayout.photoHeight)
        .defaultScrollAnchor(.leading)
        .scrollClipDisabled()
    }
}

private enum FindMapProfileTextLayout {
    static let textSpacing: CGFloat = 6
}

private struct FindMapPreviewCard: View {
    let observation: Observation
    let collapseProgress: CGFloat
    let onExpandMap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.cardInset) {
            FindMapLocationRow()

            FindMapPreviewArtwork(
                observation: observation,
                collapseProgress: collapseProgress
            )
            .overlay(alignment: .topTrailing) {
                ExpandMapButton(action: onExpandMap)
                    .padding(GaiaSpacing.cardInset)
            }
            .frame(height: FindTabLayout.mapHeight)
            .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                    .stroke(GaiaColor.border, lineWidth: 0.5)
            )

            FindMapProfileRow()
        }
        .padding(FindTabLayout.mapCardInset)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                        .stroke(GaiaColor.border, lineWidth: 0.5)
                )
        )
    }
}

private struct FindMapLocationRow: View {
    var body: some View {
        HStack(spacing: GaiaSpacing.iconGapTight) {
            GaiaIcon(kind: .pin, size: 13, tint: GaiaColor.olive)
                .frame(width: 13, height: 18)

            Text("Avila Beach, California")
                .font(.custom("Neue Haas Unica W1G", size: 17))
                .foregroundStyle(GaiaColor.olive)
                .lineLimit(1)
        }
    }
}

private struct FindMapProfileRow: View {
    var body: some View {
        HStack(spacing: GaiaSpacing.sm) {
            GaiaProfileAvatar(
                imageName: "find-avatar-alice",
                size: FindTabLayout.mapProfileAvatarSize
            )

            VStack(alignment: .leading, spacing: FindMapProfileTextLayout.textSpacing) {
                Text("Alice Edwards")
                    .font(.custom("Neue Haas Unica", size: 16))
                    .tracking(-0.31)
                    .foregroundStyle(GaiaColor.olive)
                    .lineLimit(1)
                    .minimumScaleFactor(0.95)

                Text("July 10, 2025, 10:19 AM")
                    .font(.custom("Neue Haas Unica W1G", size: 11))
                    .foregroundStyle(GaiaColor.paperWhite600)
                    .lineLimit(1)
                    .minimumScaleFactor(0.95)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct FindMapPreviewArtwork: View {
    let observation: Observation
    let collapseProgress: CGFloat

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                GaiaAssetImage(name: "find-map-figma-base", contentMode: .fill)
                    .frame(width: proxy.size.width, height: proxy.size.height)

                GaiaAssetImage(name: "find-map-figma-overlay", contentMode: .fill)
                    .frame(width: proxy.size.width, height: proxy.size.height)

                MapAnnotationPhotoPin(imageName: "find-map-figma-pin")
                    .frame(width: 63, height: 63)
                    .scaleEffect(1 - (collapseProgress * 0.02))
                    .opacity(0.98)
                    .accessibilityHidden(true)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .allowsHitTesting(false)
    }
}

private struct FindDataQualityCard: View {
    private let items: [FindQualityItemModel] = [
        .init(title: "Ungraded", state: .checked),
        .init(title: "Casual Grade", state: .checked),
        .init(title: "Research Grade", state: .unchecked)
    ]

    var body: some View {
        HStack(spacing: GaiaSpacing.lg) {
            ForEach(items) { item in
                FindQualityItem(item: item)
            }
        }
        .padding(.horizontal, GaiaSpacing.md)
        .padding(.vertical, GaiaSpacing.cardContentInsetWide)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                        .strokeBorder(GaiaColor.broccoliBrown200, lineWidth: 0.5)
                )
        )
    }
}

private struct FindQualityItemModel: Identifiable {
    let title: String
    let state: GaiaQualityCheckmarkState

    var id: String { title }

    var isActive: Bool {
        state == .checked
    }
}

private struct FindQualityItem: View {
    let item: FindQualityItemModel

    var body: some View {
        VStack(spacing: GaiaSpacing.sm) {
            GaiaQualityCheckmark(state: item.state)

            Text(item.title)
                .gaiaFont(.caption2)
                .foregroundStyle(item.isActive ? GaiaColor.dataQualityActive : GaiaColor.blackishGrey200)
                .lineLimit(2)
                .minimumScaleFactor(0.9)
                .multilineTextAlignment(.center)
        }
        .frame(width: 91)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.title)
        .accessibilityValue(item.isActive ? "Checked" : "Unchecked")
    }
}

private struct FindProjectListCard: View {
    let title: String
    let subtitle: String
    let location: String
    let imageName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: GaiaSpacing.cardInset) {
                GaiaAssetImage(name: imageName, contentMode: .fill)
                    .frame(
                        width: FindTabLayout.projectImageWidth,
                        height: FindTabLayout.projectImageHeight
                    )
                    .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                            .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
                    )

                VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                    VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                        Text(title)
                            .gaiaFont(.titleSans)
                            .foregroundStyle(GaiaColor.textPrimary)
                            .lineLimit(1)

                        Text(subtitle)
                            .gaiaFont(.caption)
                            .foregroundStyle(GaiaColor.inkBlack200)
                            .lineLimit(1)
                    }

                    HStack(spacing: 0) {
                        GaiaIcon(kind: .pin, size: 13, tint: GaiaColor.broccoliBrown500)
                            .frame(width: 13, height: 15)
                        Text(location)
                            .gaiaFont(.caption)
                            .foregroundStyle(GaiaColor.broccoliBrown500)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                GaiaIcon(kind: .circleArrowRight, size: GaiaSpacing.iconLg)
                    .frame(width: GaiaSpacing.iconLg, height: GaiaSpacing.iconLg)
            }
            .padding(FindTabLayout.mapCardInset)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: FindTabLayout.projectCardHeight, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                    .fill(GaiaColor.paperWhite50)
                    .overlay(
                        RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                            .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
