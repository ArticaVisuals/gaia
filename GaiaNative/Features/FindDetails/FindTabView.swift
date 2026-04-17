import SwiftUI

private enum FindTabLayout {
    static let contentTopInset: CGFloat = GaiaSpacing.md
    static let sectionSpacing: CGFloat = GaiaSpacing.xl
    static let sectionContentSpacing: CGFloat = GaiaSpacing.cardInset
    static let sectionHorizontalInset: CGFloat = GaiaSpacing.md

    static let mapCardContentInset: CGFloat = GaiaSpacing.cardInset
    static let mapPreviewHeight: CGFloat = 181
    static let mapPreviewCornerRadius: CGFloat = GaiaRadius.md
    static let mapProfileAvatarSize: CGFloat = 40

    static let conditionCardSpacing: CGFloat = GaiaSpacing.sm
    static let conditionCardWidth: CGFloat = 181
    static let conditionCardHeight: CGFloat = 202
    static let conditionImageHeight: CGFloat = 126
    static let conditionContentSpacing: CGFloat = GaiaSpacing.sm
    static let conditionAccessoryFrame: CGFloat = 20
    static let conditionAccessorySize: CGFloat = 16

    static let dataQualityCardVerticalInset: CGFloat = GaiaSpacing.md
    static let dataQualityCardHorizontalInset: CGFloat = GaiaSpacing.md
    static let dataQualityItemsSpacing: CGFloat = 0
    static let dataQualityItemWidth: CGFloat = 91
    static let dataQualityBadgeSize: CGFloat = GaiaSpacing.iconXl

    static let projectsSpacing: CGFloat = GaiaSpacing.cardInset
    static let projectCardHeight: CGFloat = 81
    static let projectThumbnailWidth: CGFloat = 82
    static let projectThumbnailHeight: CGFloat = 57
    static let projectArrowFrame: CGFloat = 32
    static let projectArrowSize: CGFloat = 20
}

private enum FindConditionLayout {
    static let weatherBackgroundWidthScale: CGFloat = 1.7865
    static let weatherBackgroundHeightScale: CGFloat = 2.2261
    static let weatherBackgroundLeftOffset: CGFloat = 0.0828
    static let weatherBackgroundTopOffset: CGFloat = 0.4235
}

struct FindTabView: View {
    let collapseProgress: CGFloat
    let usesCollapsedContentLayout: Bool
    let photoAssetNames: [String]
    let mapObservation: Observation
    let onExpandMap: () -> Void
    let onOpenProject: (ProjectSelection) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: FindTabLayout.sectionSpacing) {
            FindTabSection(title: "Found in") {
                FindFoundInCard(onExpandMap: onExpandMap)
            }

            VStack(alignment: .leading, spacing: FindTabLayout.sectionContentSpacing) {
                Text("Photos")
                    .gaiaFont(.titleSans)
                    .foregroundStyle(GaiaColor.inkBlack300)
                    .padding(.horizontal, FindTabLayout.sectionHorizontalInset)

                GalleryRail(imageNames: photoAssetNames)
            }

            FindTabSection(title: "Condition") {
                FindConditionCardsRow()
            }

            FindTabSection(title: "Data Quality") {
                VStack(alignment: .leading, spacing: FindTabLayout.sectionContentSpacing) {
                    FindDataQualityCard()
                    FindSectionTrailingLink(title: "Learn more", color: GaiaColor.textSecondary)
                }
            }

            FindTabSection(title: "Participating Projects") {
                VStack(alignment: .leading, spacing: FindTabLayout.projectsSpacing) {
                    FindProjectRowCard(
                        title: "Creek Recovery",
                        subtitle: "Ends tomorrow",
                        location: "Altadena, CA",
                        imageName: "find-project-creek",
                        action: {
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
                    )

                    FindProjectRowCard(
                        title: "Pollinator Corridor",
                        subtitle: "Ends in 10 days",
                        location: "Pasadena, CA",
                        imageName: "find-project-pollinator",
                        action: {
                            onOpenProject(
                                ProjectSelection(
                                    id: "project-pollinator",
                                    title: "Pollinator Corridor",
                                    tag: "Wetland",
                                    countLabel: "12",
                                    imageName: "find-project-pollinator"
                                )
                            )
                        }
                    )

                    FindSectionTrailingLink(title: "Show all", color: GaiaColor.olive)
                }
            }
        }
        .padding(.top, FindTabLayout.contentTopInset)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(GaiaColor.paperWhite50)
    }
}

private struct FindTabSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: FindTabLayout.sectionContentSpacing) {
            Text(title)
                .gaiaFont(.titleSans)
                .foregroundStyle(GaiaColor.inkBlack300)
                .padding(.horizontal, FindTabLayout.sectionHorizontalInset)

            content()
                .padding(.horizontal, FindTabLayout.sectionHorizontalInset)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct FindFoundInCard: View {
    let onExpandMap: () -> Void

    var body: some View {
        Button(action: onExpandMap) {
            VStack(alignment: .leading, spacing: GaiaSpacing.cardInset) {
                HStack(spacing: 5) {
                    GaiaAssetImage(name: "Icons/System/pin-20.png", contentMode: .fit)
                        .frame(width: 13, height: 18)

                    Text("Avila Beach, California")
                        .gaiaFont(.body)
                        .foregroundStyle(GaiaColor.olive)
                        .lineLimit(1)
                }

                ZStack(alignment: .topTrailing) {
                    FindMapArtwork()

                    FindMapExpandBadge()
                        .padding(GaiaSpacing.cardInset)
                }
                .frame(maxWidth: .infinity)
                .frame(height: FindTabLayout.mapPreviewHeight)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: FindTabLayout.mapPreviewCornerRadius,
                        style: .continuous
                    )
                )
                .overlay(
                    RoundedRectangle(
                        cornerRadius: FindTabLayout.mapPreviewCornerRadius,
                        style: .continuous
                    )
                    .strokeBorder(GaiaColor.border, lineWidth: 0.5)
                )

                HStack(spacing: GaiaSpacing.sm) {
                    GaiaProfileAvatar(
                        imageName: "find-avatar-alice",
                        size: FindTabLayout.mapProfileAvatarSize,
                        borderWidth: 0.417
                    )

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Alice Edwards")
                            .gaiaFont(.callout)
                            .foregroundStyle(GaiaColor.olive)
                            .lineLimit(1)

                        Text("July 10, 2025, 10:19 AM")
                            .gaiaFont(.caption)
                            .foregroundStyle(GaiaColor.paperWhite600)
                            .lineLimit(1)
                    }
                }
            }
            .padding(FindTabLayout.mapCardContentInset)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                    .fill(GaiaColor.paperWhite50)
                    .overlay(
                        RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                            .stroke(GaiaColor.border, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Found in Avila Beach, California")
        .accessibilityHint("Opens the expanded map")
    }
}

private struct FindMapArtwork: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                GaiaAssetImage(name: "find-map-figma-base", contentMode: .fill)
                    .frame(width: proxy.size.width, height: proxy.size.height)

                GaiaAssetImage(name: "find-map-figma-overlay", contentMode: .fill)
                    .frame(width: proxy.size.width, height: proxy.size.height)

                MapAnnotationPhotoPin(imageName: "find-map-figma-pin")
                    .frame(width: 62, height: 62)
                    .position(
                        x: proxy.size.width * 0.5,
                        y: proxy.size.height * 0.51
                    )
                    .accessibilityHidden(true)
            }
        }
        .clipped()
        .allowsHitTesting(false)
    }
}

private struct FindMapExpandBadge: View {
    var body: some View {
        GaiaMaterialBackground(cornerRadius: GaiaRadius.full, interactive: false, showsShadow: true)
            .overlay {
                GaiaIcon(kind: .expand, size: 24)
            }
            .frame(width: 40, height: 40)
            .accessibilityHidden(true)
    }
}

private struct FindConditionCardsRow: View {
    var body: some View {
        GeometryReader { proxy in
            let cardWidth = min(
                FindTabLayout.conditionCardWidth,
                max(0, (proxy.size.width - FindTabLayout.conditionCardSpacing) / 2)
            )

            HStack(alignment: .top, spacing: FindTabLayout.conditionCardSpacing) {
                FindConditionCard(
                    width: cardWidth,
                    label: "Biome",
                    title: "Riparian Edge",
                    subtitle: "Perfumo Canyon"
                ) {
                    FindBiomeConditionArtwork()
                }

                FindConditionCard(
                    width: cardWidth,
                    label: "Weather",
                    title: "Partly Cloudy",
                    subtitle: "July 10, 2025, 10:19 AM"
                ) {
                    FindWeatherConditionArtwork()
                }
            }
        }
        .frame(height: FindTabLayout.conditionCardHeight)
    }
}

private struct FindConditionCard<Artwork: View>: View {
    let width: CGFloat
    let label: String
    let title: String
    let subtitle: String
    @ViewBuilder let artwork: () -> Artwork

    private var imageShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: FindTabLayout.conditionContentSpacing) {
            artwork()
                .frame(maxWidth: .infinity)
                .frame(height: FindTabLayout.conditionImageHeight)
                .clipShape(imageShape)
                .overlay(
                    imageShape
                        .strokeBorder(GaiaColor.border, lineWidth: 0.5)
                )

            Text(label)
                .gaiaFont(.caption)
                .foregroundStyle(GaiaColor.broccoliBrown500)
                .lineLimit(1)

            HStack(alignment: .center, spacing: GaiaSpacing.sm) {
                VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                    Text(title)
                        .gaiaFont(.body)
                        .foregroundStyle(GaiaColor.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)

                    Text(subtitle)
                        .gaiaFont(.caption)
                        .foregroundStyle(GaiaColor.inkBlack200)
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                GaiaIcon(kind: .circleArrowRight, size: FindTabLayout.conditionAccessorySize)
                    .frame(
                        width: FindTabLayout.conditionAccessoryFrame,
                        height: FindTabLayout.conditionAccessoryFrame
                    )
            }
        }
        .padding(GaiaSpacing.cardInset)
        .frame(width: width, height: FindTabLayout.conditionCardHeight, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                        .strokeBorder(GaiaColor.border, lineWidth: 1)
                )
        )
    }
}

private struct FindBiomeConditionArtwork: View {
    var body: some View {
        GaiaAssetImage(name: "find-biome-riparian", contentMode: .fill)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
    }
}

private struct FindWeatherConditionArtwork: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                weatherBackground(in: proxy.size)

                Text("54º")
                    .font(GaiaTypography.weatherValue)
                    .foregroundStyle(GaiaColor.paperWhite50)
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

private struct FindDataQualityCard: View {
    private let items: [FindDataQualityItemModel] = [
        .init(title: "Ungraded", state: .checked, textColor: GaiaColor.oliveGreen400),
        .init(title: "Casual Grade", state: .checked, textColor: GaiaColor.oliveGreen400),
        .init(title: "Research Grade", state: .unchecked, textColor: GaiaColor.textDisabled)
    ]

    var body: some View {
        HStack(alignment: .top, spacing: FindTabLayout.dataQualityItemsSpacing) {
            ForEach(items) { item in
                FindDataQualityItem(item: item)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, FindTabLayout.dataQualityCardHorizontalInset)
        .padding(.vertical, FindTabLayout.dataQualityCardVerticalInset)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                        .strokeBorder(GaiaColor.border, lineWidth: 1)
                )
        )
    }
}

private struct FindDataQualityItemModel: Identifiable {
    let title: String
    let state: GaiaQualityCheckmarkState
    let textColor: Color

    var id: String { title }
}

private struct FindDataQualityItem: View {
    let item: FindDataQualityItemModel

    var body: some View {
        VStack(spacing: GaiaSpacing.sm) {
            GaiaQualityCheckmark(state: item.state, size: FindTabLayout.dataQualityBadgeSize)

            Text(item.title)
                .gaiaFont(.caption)
                .foregroundStyle(item.textColor)
                .multilineTextAlignment(.center)
                .frame(width: FindTabLayout.dataQualityItemWidth)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.title)
        .accessibilityValue(item.state == .checked ? "Active" : "Inactive")
    }
}

private struct FindProjectRowCard: View {
    let title: String
    let subtitle: String
    let location: String
    let imageName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14.962) {
                HStack(spacing: GaiaSpacing.cardInset) {
                    projectThumbnail

                    VStack(alignment: .leading, spacing: GaiaSpacing.xs) {
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
                            GaiaAssetImage(name: "Icons/System/pin-20.png", contentMode: .fit)
                                .frame(width: 13, height: 15.294)

                            Text(location)
                                .gaiaFont(.caption)
                                .foregroundStyle(GaiaColor.broccoliBrown500)
                                .lineLimit(1)
                        }
                    }
                }

                Spacer(minLength: 0)

                GaiaIcon(kind: .circleArrowRight, size: FindTabLayout.projectArrowSize)
                    .frame(
                        width: FindTabLayout.projectArrowFrame,
                        height: FindTabLayout.projectArrowFrame
                    )
            }
            .padding(GaiaSpacing.cardInset)
            .frame(maxWidth: .infinity, minHeight: FindTabLayout.projectCardHeight, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                    .fill(GaiaColor.paperWhite50)
                    .overlay(
                        RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                            .strokeBorder(GaiaColor.border, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title), \(subtitle), \(location)")
        .accessibilityHint("Opens the project details page")
    }

    private var projectThumbnail: some View {
        ZStack {
            LinearGradient(
                colors: [GaiaColor.indigoBlue100, GaiaColor.paperWhite50],
                startPoint: .top,
                endPoint: .bottom
            )

            GaiaAssetImage(name: imageName, contentMode: .fill)
        }
        .frame(width: FindTabLayout.projectThumbnailWidth, height: FindTabLayout.projectThumbnailHeight)
        .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .strokeBorder(GaiaColor.border, lineWidth: 0.5)
        )
    }
}

private struct FindSectionTrailingLink: View {
    let title: String
    let color: Color

    var body: some View {
        HStack {
            Spacer(minLength: 0)

            Text(title)
                .gaiaFont(.subheadline)
                .foregroundStyle(color)
        }
    }
}
