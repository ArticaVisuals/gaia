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
        VStack(alignment: .leading, spacing: 32) {
            LegacyFindMapPreviewCard(observation: mapObservation, onExpandMap: onExpandMap)

            VStack(alignment: .leading, spacing: 8) {
                sectionTitle("Condition")

                HStack(alignment: .top, spacing: GaiaSpacing.sm) {
                    LegacyFindConditionCard(
                        label: "Biome",
                        title: "Riparian Edge",
                        subtitle: "Perfumo Canyon"
                    ) {
                        GaiaAssetImage(name: "find-biome-riparian", contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(maxWidth: .infinity)

                    LegacyFindConditionCard(
                        label: "Weather",
                        title: "Partly Cloudy",
                        subtitle: "July 10, 2025, 10:19 AM"
                    ) {
                        LegacyFindWeatherImage()
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
            }

            VStack(alignment: .leading, spacing: 8) {
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
                    GaiaProjectCard(
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

                    GaiaProjectCard(
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

private struct LegacyFindMapPreviewCard: View {
    let observation: Observation
    let onExpandMap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
                    .padding(12)
            }
            .frame(height: 214)
            .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                    .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
            )

            LegacyFindLocationDetails()
        }
        .padding(12)
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
        HStack(spacing: 8) {
            GaiaAssetImage(name: "find-avatar-alice")
                .frame(width: 48, height: 48)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.black.opacity(0.1), lineWidth: 0.5))

            VStack(alignment: .leading, spacing: 2) {
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
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .center, spacing: 4) {
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

private struct LegacyFindConditionCard<ImageContent: View>: View {
    let label: String
    let title: String
    let subtitle: String
    @ViewBuilder let imageContent: () -> ImageContent

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            imageContent()
                .frame(maxWidth: .infinity)
                .frame(height: 126)
                .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
                )
                .clipped()

            Text(label)
                .gaiaFont(.caption)
                .foregroundStyle(GaiaColor.broccoliBrown500)

            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .gaiaFont(.body)
                        .foregroundStyle(GaiaColor.textPrimary)
                        .lineLimit(1)

                    Text(subtitle)
                        .gaiaFont(.caption)
                        .foregroundStyle(GaiaColor.inkBlack200)
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                }

                Spacer(minLength: 4)

                GaiaIcon(kind: .circleArrowRight, size: 16)
                    .padding(.top, 1)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 202, maxHeight: 202, alignment: .topLeading)
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

private struct LegacyFindWeatherImage: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                GaiaAssetImage(name: "find-weather-bg", contentMode: .fill)
                    .frame(width: proxy.size.width * 1.7865, height: proxy.size.height * 2.2261)
                    .offset(x: -(proxy.size.width * 0.0828), y: -(proxy.size.height * 0.4235))

                Text("54º")
                    .font(.custom("NewSpirit-Regular", size: 69.5))
                    .foregroundStyle(GaiaColor.paperWhite500)
                    .tracking(-1.09)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
    }
}

private struct LegacyFindDataQualityCard: View {
    var body: some View {
        HStack(spacing: 24) {
            LegacyFindQualityItem(
                title: "Ungraded",
                imageName: "find-dq-checked",
                isActive: true
            )
            LegacyFindQualityItem(
                title: "Casual Grade",
                imageName: "find-dq-checked",
                isActive: true
            )
            LegacyFindQualityItem(
                title: "Research Grade",
                imageName: "find-dq-unchecked",
                isActive: false
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
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

private struct LegacyFindQualityItem: View {
    let title: String
    let imageName: String
    let isActive: Bool

    var body: some View {
        VStack(spacing: 8) {
            GaiaAssetImage(name: imageName, contentMode: .fit)
                .frame(width: 40, height: 40)

            Text(title)
                .gaiaFont(.caption)
                .foregroundStyle(isActive ? GaiaColor.olive : GaiaColor.blackishGrey200)
                .lineLimit(1)
                .minimumScaleFactor(0.9)
                .multilineTextAlignment(.center)
        }
        .frame(width: 91)
    }
}
