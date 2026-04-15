import SwiftUI

struct FindDetailsLegacyTabView: View {
    let species: Species
    let observations: [Observation]
    let onExpandMap: () -> Void
    let onOpenProject: (ProjectSelection) -> Void

    private enum FindReference {
        static let latitude = 35.1797
        static let longitude = -120.7361
    }

    private var mapObservation: Observation {
        Observation(
            id: "\(species.id)-find-preview",
            speciesID: species.id,
            latitude: FindReference.latitude,
            longitude: FindReference.longitude,
            thumbnailAssetName: species.galleryAssetNames.first ?? observations.first?.thumbnailAssetName
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.xl) {
            LegacyFindMapPreviewCard(observation: mapObservation, onExpandMap: onExpandMap)

            VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                Text("Condition")
                    .gaiaFont(.titleSans)
                    .foregroundStyle(GaiaColor.inkBlack300)

                FindConditionCardsRow()
            }

            VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                sectionTitle("Data Quality")
                LegacyFindDataQualityCard()
            }

            VStack(alignment: .leading, spacing: GaiaSpacing.cardInset) {
                HStack(alignment: .center) {
                    Text("Projects")
                        .gaiaFont(.title2)
                        .foregroundStyle(GaiaColor.inkBlack300)

                    Spacer()

                    Text("See all")
                        .gaiaFont(.caption2)
                        .foregroundStyle(GaiaColor.inkBlack300)
                }

                HStack(alignment: .top, spacing: GaiaSpacing.sm) {
                    LegacyFindProjectCard(
                        tag: "Wetland",
                        title: "Creek Recovery",
                        countLabel: "12",
                        imageName: "find-project-creek",
                        crop: .init(scaleX: 1.1289, scaleY: 1.0264, left: 0.105, top: 0.019)
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
                    .frame(maxWidth: .infinity)

                    LegacyFindProjectCard(
                        tag: "Garden",
                        title: "Pollinator Corridor",
                        countLabel: "9",
                        imageName: "find-project-pollinator",
                        crop: .init(scaleX: 1.2061, scaleY: 1.0966, left: 0.2044, top: 0.0228)
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
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, GaiaSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .gaiaFont(.title3)
            .foregroundStyle(GaiaColor.inkBlack300)
    }
}

private struct LegacyFindProjectCardCrop: Hashable {
    let scaleX: CGFloat
    let scaleY: CGFloat
    let left: CGFloat
    let top: CGFloat

    static let identity = Self(scaleX: 1, scaleY: 1, left: 0, top: 0)
}

private struct LegacyFindProjectCard: View {
    let tag: String
    let title: String
    let countLabel: String
    let imageName: String
    var crop: LegacyFindProjectCardCrop = .identity
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topLeading) {
                GeometryReader { proxy in
                    let imageWidth = proxy.size.width * crop.scaleX
                    let imageHeight = proxy.size.height * crop.scaleY
                    let imageOffsetX = -(proxy.size.width * crop.left)
                    let imageOffsetY = -(proxy.size.height * crop.top)

                    ZStack {
                        GaiaAssetImage(name: imageName, contentMode: .fill)
                            .frame(width: imageWidth, height: imageHeight)
                            .offset(x: imageOffsetX, y: imageOffsetY)

                        GaiaAssetImage(name: imageName, contentMode: .fill)
                            .frame(width: imageWidth, height: imageHeight)
                            .offset(x: imageOffsetX, y: imageOffsetY)
                            .blur(radius: 1.4)
                            .mask(
                                LinearGradient(
                                    stops: [
                                        .init(color: .clear, location: 0.417),
                                        .init(color: .black, location: 1)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        LinearGradient(
                            stops: [
                                .init(color: GaiaColor.projectCardOverlay.opacity(0), location: 0.417),
                                .init(color: GaiaColor.projectCardOverlay.opacity(0.85), location: 1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                }
                .clipped()

                VStack(alignment: .leading, spacing: 0) {
                    Text(tag)
                        .gaiaFont(.caption)
                        .foregroundStyle(GaiaColor.paperWhite50)
                        .padding(.horizontal, GaiaSpacing.pillHorizontal)
                        .frame(height: 20)
                        .background(Color.black.opacity(0.5), in: Capsule())
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(GaiaColor.blackishGrey200, lineWidth: 0.5)
                        )
                        .padding(GaiaSpacing.cardInset)

                    Spacer(minLength: 0)

                    VStack(alignment: .leading, spacing: GaiaSpacing.xs) {
                        Text(title)
                            .gaiaFont(.calloutTight)
                            .foregroundStyle(GaiaColor.paperWhite50)
                            .lineLimit(2)
                            .minimumScaleFactor(0.9)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(spacing: GaiaSpacing.xxs) {
                            LegacyFindProjectCardBinocularsIcon(tint: GaiaColor.paperWhite50)

                            Text(countLabel)
                                .gaiaFont(.micro)
                                .foregroundStyle(GaiaColor.paperWhite50)
                                .lineLimit(1)
                        }
                    }
                    .padding(GaiaSpacing.cardInset)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 133)
            .background(GaiaColor.blackishGrey50)
            .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                    .stroke(GaiaColor.blackishGrey200, lineWidth: 0.5)
            )
            .shadow(color: GaiaShadow.cardColor, radius: GaiaShadow.cardRadius, x: 0, y: GaiaShadow.mdYOffset)
            .contentShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title), \(tag) project, \(countLabel) finds")
        .accessibilityHint("Opens the project details page")
    }
}

private struct LegacyFindProjectCardBinocularsIcon: View {
    let tint: Color

    var body: some View {
        Group {
            if let image = AssetCatalog.uiImage(named: "Icons/System/binoculars-20.png") {
                Image(uiImage: image)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(tint)
            } else {
                GaiaIcon(kind: .observe(selected: false), size: 14, tint: tint)
            }
        }
        .frame(width: 14, height: 10)
    }
}

private struct LegacyFindMapPreviewCard: View {
    let observation: Observation
    let onExpandMap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
            LegacyFindMapProfileRow()

            ZStack {
                ExploreMapView(
                    observations: [observation],
                    recenterRequestID: nil,
                    onSelectObservation: nil,
                    showsMarkers: false,
                    initialZoomOverride: 13.0
                )
                .allowsHitTesting(false)

                LegacyFindMapInteractionShield()

                MapAnnotationPhotoPin(imageName: observation.thumbnailAssetName)
                    .frame(width: 63, height: 63)
            }
            .overlay(alignment: .topTrailing) {
                ExpandMapButton(action: onExpandMap)
                    .padding(GaiaSpacing.cardInset)
            }
            .frame(height: 214)
            .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                    .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
            )

            LegacyFindLocationDetails()
        }
        .padding(GaiaSpacing.cardInset)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
                )
        )
        .shadow(color: GaiaShadow.mdColor, radius: GaiaShadow.mdRadius, x: 0, y: GaiaShadow.mdYOffset)
    }
}

private struct LegacyFindMapInteractionShield: View {
    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in }
            )
            .onTapGesture { }
    }
}

private struct LegacyFindMapProfileRow: View {
    var body: some View {
        HStack(spacing: GaiaSpacing.sm) {
            GaiaAssetImage(name: "find-avatar-alice")
                .frame(width: 48, height: 48)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.black.opacity(0.1), lineWidth: 0.5))

            VStack(alignment: .leading, spacing: GaiaSpacing.xxs) {
                Text("Alice Edwards")
                    .gaiaFont(.subheadSerif)
                    .foregroundStyle(GaiaColor.olive)
                    .lineLimit(1)

                Text("127 finds")
                    .gaiaFont(.caption)
                    .foregroundStyle(GaiaColor.broccoliBrown500)
                    .lineLimit(1)
            }
        }
    }
}

private struct LegacyFindLocationDetails: View {
    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.xxs) {
            HStack(alignment: .center, spacing: GaiaSpacing.xs) {
                GaiaAssetImage(name: "Icons/System/pin-20.png", contentMode: .fit)
                    .frame(width: 10, height: 21)
                    .opacity(0.48)

                Text("Avila Beach, CA, United States of America")
                    .gaiaFont(.subheadline)
                    .foregroundStyle(GaiaColor.blackishGrey400)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }

            Text("July 10, 2025, 10:19 AM")
                .gaiaFont(.caption)
                .foregroundStyle(GaiaColor.inkBlack200)
                .lineLimit(1)
        }
    }
}

private struct LegacyFindDataQualityCard: View {
    private let items: [(title: String, state: GaiaQualityCheckmarkState)] = [
        ("Ungraded", .checked),
        ("Casual Grade", .checked),
        ("Research Grade", .unchecked)
    ]

    var body: some View {
        HStack(alignment: .top, spacing: GaiaSpacing.lg) {
            ForEach(items, id: \.title) { item in
                LegacyFindQualityItem(
                    title: item.title,
                    state: item.state
                )
                .frame(maxWidth: .infinity, alignment: .top)
            }
        }
        .padding(.horizontal, GaiaSpacing.md)
        .padding(.vertical, GaiaSpacing.cardContentInsetWide)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                        .strokeBorder(GaiaColor.broccoliBrown200, lineWidth: 0.5)
                )
        )
        .shadow(color: GaiaShadow.mdColor, radius: GaiaShadow.mdRadius, x: 0, y: GaiaShadow.mdYOffset)
    }
}

private struct LegacyFindQualityItem: View {
    let title: String
    let state: GaiaQualityCheckmarkState

    private var isActive: Bool {
        state == .checked
    }

    var body: some View {
        VStack(spacing: GaiaSpacing.sm) {
            GaiaQualityCheckmark(state: state)

            Text(title)
                .gaiaFont(.caption2)
                .foregroundStyle(isActive ? GaiaColor.dataQualityActive : GaiaColor.blackishGrey200)
                .lineLimit(2)
                .minimumScaleFactor(0.9)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(isActive ? "Checked" : "Unchecked")
    }
}
