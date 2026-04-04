import SwiftUI

struct FindTabView: View {
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
            FindMapPreviewCard(observation: mapObservation, onExpandMap: onExpandMap)

            VStack(alignment: .leading, spacing: 8) {
                sectionTitle("Condition")

                HStack(alignment: .top, spacing: GaiaSpacing.sm) {
                    FindConditionCard(
                        label: "Biome",
                        title: "Riparian Edge",
                        subtitle: "Perfumo Canyon"
                    ) {
                        GaiaAssetImage(name: "find-biome-riparian", contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(maxWidth: .infinity)

                    FindConditionCard(
                        label: "Weather",
                        title: "Partly Cloudy",
                        subtitle: "July 10, 2025, 10:19 AM"
                    ) {
                        FindWeatherImage()
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
            }

            VStack(alignment: .leading, spacing: 8) {
                sectionTitle("Data Quality")
                FindDataQualityCard()
            }

            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center) {
                    sectionTitle("Projects")
                    Spacer()
                    Text("See all")
                        .gaiaFont(.subheadline)
                        .foregroundStyle(GaiaColor.olive)
                }

                HStack(alignment: .top, spacing: GaiaSpacing.sm) {
                    FindProjectCard(
                        tag: "Wetland",
                        title: "Creek Recovery",
                        count: "12",
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

                    FindProjectCard(
                        tag: "Garden",
                        title: "Pollinator Corridor",
                        count: "9",
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

private struct FindMapPreviewCard: View {
    let observation: Observation
    let onExpandMap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            FindMapProfileRow()

            ZStack {
                ExploreMapView(
                    observations: [observation],
                    recenterRequestID: nil,
                    onSelectObservation: nil,
                    showsMarkers: false,
                    initialZoomOverride: 13.0
                )
                .allowsHitTesting(false)

                FindMapInteractionShield()

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

            FindLocationDetails()
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

private struct FindMapInteractionShield: View {
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

private struct FindMapProfileRow: View {
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

private struct FindLocationDetails: View {
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

private struct FindConditionCard<ImageContent: View>: View {
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

private struct FindWeatherImage: View {
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

private struct FindDataQualityCard: View {
    var body: some View {
        HStack(spacing: 24) {
            FindQualityItem(
                title: "Ungraded",
                imageName: "find-dq-checked",
                isActive: true
            )
            FindQualityItem(
                title: "Casual Grade",
                imageName: "find-dq-checked",
                isActive: true
            )
            FindQualityItem(
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

private struct FindQualityItem: View {
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

private struct FindProjectImageCrop {
    let scaleX: CGFloat
    let scaleY: CGFloat
    let left: CGFloat
    let top: CGFloat
}

private struct FindProjectCard: View {
    let tag: String
    let title: String
    let count: String
    let imageName: String
    let crop: FindProjectImageCrop
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topLeading) {
                GeometryReader { proxy in
                    ZStack(alignment: .topLeading) {
                        let imageWidth = proxy.size.width * crop.scaleX
                        let imageHeight = proxy.size.height * crop.scaleY
                        let imageOffsetX = -(proxy.size.width * crop.left)
                        let imageOffsetY = -(proxy.size.height * crop.top)

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
                                .init(color: Color(red: 70 / 255, green: 76 / 255, blue: 19 / 255, opacity: 0), location: 0.417),
                                .init(color: Color(red: 41 / 255, green: 76 / 255, blue: 19 / 255, opacity: 0.85), location: 1)
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
                        .padding(.horizontal, 10)
                        .frame(height: 20)
                        .background(Color.black.opacity(0.5), in: Capsule())
                        .overlay(
                            Capsule()
                                .stroke(GaiaColor.blackishGrey200, lineWidth: 0.5)
                        )
                        .padding(12)

                    Spacer(minLength: 0)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .gaiaFont(.subheadSerif)
                            .foregroundStyle(GaiaColor.paperWhite50)
                            .lineLimit(1)
                            .minimumScaleFactor(0.9)

                        HStack(spacing: 2) {
                            FindBinocularsIcon(tint: GaiaColor.paperWhite50)
                            Text(count)
                                .font(.custom("Neue Haas Unica W1G", size: 10))
                                .foregroundStyle(GaiaColor.paperWhite50)
                                .tracking(0.25)
                        }
                    }
                    .padding(12)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 133)
            .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                    .stroke(GaiaColor.blackishGrey200, lineWidth: 0.5)
            )
            .shadow(color: GaiaShadow.mdColor, radius: GaiaShadow.mdRadius, x: 0, y: GaiaShadow.mdYOffset)
            .contentShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title), \(tag) project, \(count) finds")
        .accessibilityHint("Opens the project details page")
    }
}

private struct FindBinocularsIcon: View {
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
                GaiaIcon(kind: .observe(selected: false), size: 14)
                    .foregroundStyle(tint)
            }
        }
        .frame(width: 14, height: 10)
    }
}
