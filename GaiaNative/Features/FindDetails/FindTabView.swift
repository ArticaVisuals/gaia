import SwiftUI

struct FindTabView: View {
    let species: Species
    let observations: [Observation]
    let onExpandMap: () -> Void

    private enum FindReference {
        static let latitude = 35.1797
        static let longitude = -120.7361
    }

    private var pairedCardWidth: CGFloat {
        ((UIScreen.main.bounds.width) - (GaiaSpacing.md * 2) - GaiaSpacing.sm) / 2
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
        VStack(alignment: .leading, spacing: 10) {
            FindMapPreviewCard(observation: mapObservation, onExpandMap: onExpandMap)

            VStack(alignment: .leading, spacing: 10) {
                sectionTitle("Condition")

                HStack(alignment: .top, spacing: GaiaSpacing.sm) {
                    FindConditionCard(
                        label: "Biome",
                        title: "Riparian Edge",
                        subtitle: "Perfumo Canyon"
                    ) {
                        ZStack {
                            LinearGradient(
                                colors: [
                                    Color(red: 213 / 255, green: 218 / 255, blue: 229 / 255),
                                    GaiaColor.paperWhite50
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )

                            GaiaAssetImage(name: "find-biome-riparian", contentMode: .fit)
                                .frame(width: 107, height: 102)
                        }
                    }
                    .frame(width: pairedCardWidth)

                    FindConditionCard(
                        label: "Weather",
                        title: "Partly Cloudy",
                        subtitle: "July 10, 2025, 10:19 AM"
                    ) {
                        ZStack {
                            GaiaAssetImage(name: "find-weather-bg", contentMode: .fill)
                                .scaleEffect(1.14)
                            LinearGradient(
                                colors: [Color.white.opacity(0.08), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            Text("54º")
                                .font(.custom("NewSpirit-Regular", size: 69.5))
                                .foregroundStyle(GaiaColor.paperWhite500)
                                .tracking(-1.09)
                                .padding(.top, 6)
                        }
                    }
                    .frame(width: pairedCardWidth)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                sectionTitle("Data Quality")
                FindDataQualityCard()
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center) {
                    sectionTitle("Projects")
                    Spacer()
                    Text("See all")
                        .font(.custom("Neue Haas Unica W1G", size: 12))
                        .foregroundStyle(GaiaColor.olive)
                }

                HStack(alignment: .top, spacing: GaiaSpacing.sm) {
                    FindProjectCard(
                        tag: "Wetland",
                        title: "Creek Recovery",
                        count: "12",
                        imageName: "find-project-creek"
                    )
                    .frame(width: pairedCardWidth)

                    FindProjectCard(
                        tag: "Garden",
                        title: "Pollinator Corridor",
                        count: "9",
                        imageName: "find-project-pollinator"
                    )
                    .frame(width: pairedCardWidth)
                }
            }
        }
        .padding(.horizontal, GaiaSpacing.md)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(GaiaTypography.titleRegular)
            .foregroundStyle(GaiaColor.inkBlack300)
    }
}

private struct FindMapPreviewCard: View {
    let observation: Observation
    let onExpandMap: () -> Void

    var body: some View {
        ZStack {
            ExploreMapView(
                observations: [observation],
                recenterRequestID: nil,
                onSelectObservation: nil,
                showsMarkers: false,
                initialZoomOverride: 13.0
            )
            .allowsHitTesting(false)
        }
        .overlay(alignment: .topLeading) {
            HStack(alignment: .top) {
                FindMapProfileCard()
                Spacer(minLength: 12)
                ExpandMapButton(action: onExpandMap)
            }
            .padding(.top, 12)
            .padding(.horizontal, 12)
        }
        .overlay(alignment: .center) {
            MapAnnotationPhotoPin(imageName: observation.thumbnailAssetName)
                .frame(width: 63, height: 63)
                .offset(y: 10)
        }
        .overlay(alignment: .bottom) {
            FindLocationCard()
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
        }
        .frame(height: 214)
        .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
        )
        .shadow(color: GaiaShadow.mdColor, radius: GaiaShadow.mdRadius, x: 0, y: GaiaShadow.mdYOffset)
    }
}

private struct FindMapProfileCard: View {
    var body: some View {
        HStack(spacing: 8) {
            GaiaAssetImage(name: "find-avatar-alice")
                .frame(width: 44, height: 44)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.black.opacity(0.1), lineWidth: 0.5))

            VStack(alignment: .leading, spacing: 2) {
                Text("Alice Edwards")
                    .font(.custom("NewSpirit-Regular", size: 16))
                    .foregroundStyle(GaiaColor.olive)
                    .lineLimit(1)
                Text("127 finds")
                    .font(.custom("Neue Haas Unica W1G", size: 11))
                    .foregroundStyle(GaiaColor.broccoliBrown500)
                    .lineLimit(1)
            }
        }
        .fixedSize(horizontal: true, vertical: false)
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .fill(GaiaColor.paperWhite50.opacity(0.985))
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                        .stroke(Color.black.opacity(0.06), lineWidth: 0.5)
                )
        )
        .shadow(color: GaiaShadow.smallColor, radius: 18, x: 0, y: 4)
    }
}

private struct FindLocationCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .center, spacing: 6) {
                GaiaAssetImage(name: "Icons/System/pin-20.png", contentMode: .fit)
                    .frame(width: 10, height: 20)
                    .opacity(0.48)
                Text("Avila Beach, CA, United States of America")
                    .font(.custom("Neue Haas Unica W1G", size: 11))
                    .foregroundStyle(GaiaColor.blackishGrey400)
                    .lineLimit(1)
                    .minimumScaleFactor(0.88)
            }

            Text("July 10, 2025, 10:19 AM")
                .font(.custom("Neue Haas Unica W1G", size: 10))
                .foregroundStyle(GaiaColor.inkBlack200)
                .tracking(0.25)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .fill(GaiaColor.paperWhite50.opacity(0.985))
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                        .stroke(Color.black.opacity(0.06), lineWidth: 0.5)
                )
        )
        .shadow(color: GaiaShadow.smallColor, radius: 18, x: 0, y: 4)
    }
}

private struct FindConditionCard<ImageContent: View>: View {
    let label: String
    let title: String
    let subtitle: String
    @ViewBuilder let imageContent: () -> ImageContent

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.custom("Neue Haas Unica W1G", size: 10))
                .foregroundStyle(GaiaColor.broccoliBrown500)
                .tracking(0.25)

            imageContent()
                .frame(maxWidth: .infinity)
                .frame(height: 122)
                .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
                )
                .clipped()

            HStack(alignment: .top, spacing: 6) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(GaiaTypography.body)
                        .foregroundStyle(GaiaColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(subtitle)
                        .font(.custom("Neue Haas Unica W1G", size: 10))
                        .foregroundStyle(GaiaColor.inkBlack200)
                        .tracking(0.25)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 4)
                FindCircleArrowIcon()
                    .padding(.top, 2)
            }
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

private struct FindDataQualityCard: View {
    var body: some View {
        HStack(spacing: 18) {
            FindQualityItem(title: "Ungraded", state: .active)
            FindQualityItem(title: "Casual Grade", state: .active)
            FindQualityItem(title: "Research Grade", state: .inactive)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
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

private enum FindQualityState {
    case active
    case inactive
}

private struct FindQualityItem: View {
    let title: String
    let state: FindQualityState

    var body: some View {
        VStack(spacing: 6) {
            FindQualityBadge(state: state)
            Text(title)
                .font(.custom("Neue Haas Unica W1G", size: 11))
                .foregroundStyle(state == .active ? GaiaColor.olive : GaiaColor.blackishGrey200)
                .tracking(0.25)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct FindQualityBadge: View {
    let state: FindQualityState

    var body: some View {
        ZStack {
            Circle()
                .fill(state == .active ? GaiaColor.olive : .clear)
                .overlay(
                    Circle()
                        .stroke(state == .active ? GaiaColor.olive : GaiaColor.blackishGrey200, lineWidth: 1.4)
                )

            if state == .active {
                Path { path in
                    path.move(to: CGPoint(x: 10.5, y: 20.2))
                    path.addLine(to: CGPoint(x: 17.1, y: 26.3))
                    path.addLine(to: CGPoint(x: 29.3, y: 13.7))
                }
                .stroke(GaiaColor.paperWhite50, style: StrokeStyle(lineWidth: 2.1, lineCap: .round, lineJoin: .round))
            }
        }
        .frame(width: 36, height: 36)
    }
}

private struct FindProjectCard: View {
    let tag: String
    let title: String
    let count: String
    let imageName: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            GaiaAssetImage(name: imageName, contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 133)
                .blur(radius: 1.4)
                .overlay(
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.72)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipped()

            VStack(alignment: .leading, spacing: 0) {
                Text(tag)
                    .font(.custom("Neue Haas Unica W1G", size: 11))
                    .foregroundStyle(GaiaColor.paperWhite50)
                    .tracking(0.25)
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
                        .font(.custom("NewSpirit-Regular", size: 16))
                        .foregroundStyle(GaiaColor.paperWhite50)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                        .minimumScaleFactor(0.92)

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
    }
}

private struct FindCircleArrowIcon: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(GaiaColor.blackishGrey200, lineWidth: 0.7)

            Path { path in
                path.move(to: CGPoint(x: 6.2, y: 4.5))
                path.addLine(to: CGPoint(x: 10.2, y: 8))
                path.addLine(to: CGPoint(x: 6.2, y: 11.5))
            }
            .stroke(GaiaColor.broccoliBrown500, style: StrokeStyle(lineWidth: 1.1, lineCap: .round, lineJoin: .round))
        }
        .frame(width: 16, height: 16)
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
