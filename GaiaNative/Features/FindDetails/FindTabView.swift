import SwiftUI

private enum FindTabLayout {
    static let sectionSpacing: CGFloat = 32
    static let cardSpacing: CGFloat = 8
    static let conditionCardWidth: CGFloat = 181
    static let mapHeight: CGFloat = 181
    static let mapCardInset: CGFloat = 12
    static let photoHeight: CGFloat = 134
    static let photoCornerRadius: CGFloat = GaiaRadius.md
    static let conditionHeight: CGFloat = 206
    static let projectCardHeight: CGFloat = 72

    static var conditionRowWidth: CGFloat {
        (conditionCardWidth * 2) + cardSpacing
    }
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
                    FindConditionRow()
                }

                section(title: "Data Quality") {
                    FindDataQualityCard()
                }

                section(title: "Participating Projects") {
                    VStack(alignment: .leading, spacing: 8) {
                        FindProjectListCard(
                            eyebrow: nil,
                            title: "Creek Recovery",
                            subtitle: "Ends tomorrow",
                            imageName: "coast-live-oak-gallery-2",
                            showsAccessory: usesCollapsedContentLayout
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
                            eyebrow: usesCollapsedContentLayout ? nil : "Garden",
                            title: "Pollinator Corridor",
                            subtitle: usesCollapsedContentLayout ? "Ends in 10 days" : nil,
                            imageName: usesCollapsedContentLayout ? "find-project-pollinator" : "coast-live-oak-gallery-2",
                            showsAccessory: usesCollapsedContentLayout
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

                        if !usesCollapsedContentLayout {
                            FindSectionFooterLink(title: "Show all")
                        }
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

private struct FindConditionRow: View {
    var body: some View {
        HStack(alignment: .top, spacing: FindTabLayout.cardSpacing) {
            FindConditionCard(
                label: "Biome",
                title: "Riparian Edge",
                subtitle: nil
            ) {
                FindBiomeImage()
            }
            .frame(width: FindTabLayout.conditionCardWidth)

            FindConditionCard(
                label: "Weather",
                title: "Partly Cloudy",
                subtitle: nil
            ) {
                FindWeatherImage()
            }
            .frame(width: FindTabLayout.conditionCardWidth)
        }
        .frame(width: FindTabLayout.conditionRowWidth, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: FindTabLayout.conditionHeight)
    }
}

private struct FindSectionFooterLink: View {
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
    static let nameMinHeight: CGFloat = 17.6
    static let nameTracking: CGFloat = -0.31
    static let timestampMinHeight: CGFloat = 14.3
    static let timestampTracking: CGFloat = 0.25
}

private struct FindMapPreviewCard: View {
    let observation: Observation
    let collapseProgress: CGFloat
    let onExpandMap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            FindMapLocationRow()

            ZStack(alignment: .topTrailing) {
                FindMapPreviewArtwork()

                MapAnnotationPhotoPin(imageName: observation.thumbnailAssetName)
                    .frame(width: 63, height: 63)

                ExpandMapButton(action: onExpandMap)
                    .padding(12)
            }
            .frame(height: FindTabLayout.mapHeight)
            .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                    .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
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
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
                )
        )
    }
}

private struct FindMapLocationRow: View {
    var body: some View {
        HStack(spacing: GaiaSpacing.iconGapTight) {
            GaiaAssetImage(name: "Icons/System/pin-20.png", contentMode: .fit)
                .frame(width: 13, height: 18)
                .opacity(0.55)

            Text("Avila Beach, California")
                .gaiaFont(.body)
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
                size: 40,
                borderWidth: 0.417
            )

            VStack(alignment: .leading, spacing: 4) {
                Text("Alice Edwards")
                    .font(GaiaTypography.callout)
                    .tracking(FindMapProfileTextLayout.nameTracking)
                    .foregroundStyle(GaiaColor.olive)
                    .frame(minHeight: FindMapProfileTextLayout.nameMinHeight, alignment: .topLeading)
                    .lineLimit(1)

                Text("July 10, 2025, 10:19 AM")
                    .font(GaiaTypography.caption)
                    .tracking(FindMapProfileTextLayout.timestampTracking)
                    .foregroundStyle(GaiaColor.paperWhite600)
                    .frame(minHeight: FindMapProfileTextLayout.timestampMinHeight, alignment: .topLeading)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct FindMapPreviewArtwork: View {
    var body: some View {
        ZStack {
            GaiaAssetImage(name: "find-map-preview-base", contentMode: .fill)
            GaiaAssetImage(name: "find-map-preview-overlay", contentMode: .fill)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .allowsHitTesting(false)
    }
}

private enum FindConditionCardLayout {
    static let imageHeight: CGFloat = 126
    static let cardInset: CGFloat = 12
    static let contentSpacing: CGFloat = 8
}

private struct FindConditionCard<ImageContent: View>: View {
    let label: String
    let title: String
    let subtitle: String?
    @ViewBuilder let imageContent: () -> ImageContent

    init(
        label: String,
        title: String,
        subtitle: String?,
        @ViewBuilder imageContent: @escaping () -> ImageContent
    ) {
        self.label = label
        self.title = title
        self.subtitle = subtitle
        self.imageContent = imageContent
    }

    private var imageShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: FindConditionCardLayout.contentSpacing) {
            ZStack {
                imageContent()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity)
            .frame(height: FindConditionCardLayout.imageHeight)
            .compositingGroup()
            .clipShape(imageShape)
            .overlay(
                imageShape
                    .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
            )

            Text(label)
                .gaiaFont(.caption)
                .foregroundStyle(GaiaColor.broccoliBrown500)
                .lineLimit(1)

            VStack(alignment: .leading, spacing: FindConditionCardLayout.contentSpacing) {
                Text(title)
                    .gaiaFont(.titleSans)
                    .foregroundStyle(GaiaColor.olive)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                    .allowsTightening(true)

                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .gaiaFont(.caption)
                        .foregroundStyle(GaiaColor.paperWhite600)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(FindConditionCardLayout.cardInset)
        .frame(height: FindTabLayout.conditionHeight, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
                )
        )
    }
}

private struct FindBiomeImage: View {
    var body: some View {
        GaiaAssetImage(name: "find-biome-riparian", contentMode: .fill)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct FindWeatherImage: View {
    private enum Layout {
        static let backgroundWidthScale: CGFloat = 1.7865
        static let backgroundHeightScale: CGFloat = 2.2261
        static let backgroundLeftOffset: CGFloat = 0.0828
        static let backgroundTopOffset: CGFloat = 0.4235
    }

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
                    width: size.width * Layout.backgroundWidthScale,
                    height: size.height * Layout.backgroundHeightScale
                )
                .offset(
                    x: -(size.width * Layout.backgroundLeftOffset),
                    y: -(size.height * Layout.backgroundTopOffset)
                )
        } else {
            GaiaAssetImage(name: "find-weather-bg", contentMode: .fill)
                .frame(
                    width: size.width * Layout.backgroundWidthScale,
                    height: size.height * Layout.backgroundHeightScale
                )
                .offset(
                    x: -(size.width * Layout.backgroundLeftOffset),
                    y: -(size.height * Layout.backgroundTopOffset)
                )
        }
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
    let eyebrow: String?
    let title: String
    let subtitle: String?
    let imageName: String
    let showsAccessory: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: GaiaSpacing.sm) {
                GaiaAssetImage(name: imageName, contentMode: .fill)
                    .frame(width: 80, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))

                VStack(alignment: .leading, spacing: textStackSpacing) {
                    if let eyebrow, !eyebrow.isEmpty {
                        Text(eyebrow)
                            .gaiaFont(.caption)
                            .foregroundStyle(GaiaColor.inkBlack300)
                            .lineLimit(1)
                    }

                    Text(title)
                        .gaiaFont(.title3)
                        .foregroundStyle(GaiaColor.olive)
                        .lineLimit(1)

                    if let subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .gaiaFont(.caption)
                            .foregroundStyle(GaiaColor.inkBlack300)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if showsAccessory {
                    GaiaIcon(kind: .circleArrowRight, size: 16, tint: GaiaColor.olive.opacity(0.35))
                        .frame(width: 32, height: 32)
                }
            }
            .padding(GaiaSpacing.sm)
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

    private var textStackSpacing: CGFloat {
        if let eyebrow, !eyebrow.isEmpty {
            return 8
        }
        if let subtitle, !subtitle.isEmpty {
            return 4
        }
        return 0
    }
}
