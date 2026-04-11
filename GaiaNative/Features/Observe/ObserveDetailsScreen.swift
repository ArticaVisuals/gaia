// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=917-10873
import SwiftUI

private enum ObserveDetailsLayout {
    static let toolbarButtonSize: CGFloat = 48
    static let photoCardHeight: CGFloat = 112
    static let highlightCardWidth: CGFloat = 181
    static let squareCardWidth: CGFloat = 112
    static let portraitCardWidth: CGFloat = 84
    static let addCardWidth: CGFloat = 60
    static let notesHeight: CGFloat = 125
    static let mapHeight: CGFloat = 214
    static let conditionCardWidth: CGFloat = 181
    static let actionButtonHeight: CGFloat = 50
}

struct ObserveDetailsScreen: View {
    let onBack: () -> Void
    let onContinue: () -> Void

    @State private var notesText = ""
    @State private var showsExpandedMap = false

    private let draftObservation = Observation(
        id: "observe-draft-1",
        speciesID: "observe-draft",
        latitude: 34.14,
        longitude: -118.14,
        thumbnailAssetName: "observe-photo-square"
    )

    var body: some View {
        GeometryReader { proxy in
            let toolbarTopPadding = min(max(19, proxy.safeAreaInsets.top + 4), 51)
            let topBarHeight = toolbarTopPadding + ObserveDetailsLayout.toolbarButtonSize + GaiaSpacing.md
            let bottomSafeInset = windowSafeBottomInset > 0 ? windowSafeBottomInset : proxy.safeAreaInsets.bottom
            let bottomBarHeight = GaiaSpacing.md + ObserveDetailsLayout.actionButtonHeight + max(GaiaSpacing.md, bottomSafeInset)
            let contentWidth = max(0, proxy.size.width - (GaiaSpacing.md * 2))

            ZStack(alignment: .top) {
                GaiaColor.paperWhite50.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: GaiaSpacing.xl) {
                        ObserveDetailsPhotoStrip()

                        VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                            ObserveDetailsSectionTitle(title: "Identification")
                            ObserveIdentificationCard()
                        }

                        VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                            ObserveDetailsSectionTitle(title: "Notes")
                            ObserveNotesField(text: $notesText)
                        }

                        ObserveMapDataCard(
                            observation: draftObservation,
                            onExpandMap: { showsExpandedMap = true }
                        )

                        VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                            ObserveDetailsSectionTitle(title: "Details")
                            ObserveMetadataCard()
                        }

                        VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                            Text("Condition")
                                .gaiaFont(.title3)
                                .foregroundStyle(GaiaColor.oliveGreen500)

                            HStack(spacing: GaiaSpacing.sm) {
                                ObserveConditionCard(
                                    label: "Biome",
                                    title: "Riparian Edge",
                                    subtitle: "Perfumo Canyon",
                                    showsActionIcon: false
                                )
                                ObserveConditionCard(
                                    label: "Weather",
                                    title: "Partly Cloudy",
                                    subtitle: "Mar 22, 2026 · 10:53 PM PT",
                                    showsActionIcon: true
                                )
                            }
                        }
                    }
                    .frame(width: contentWidth, alignment: .leading)
                    .padding(.horizontal, GaiaSpacing.md)
                    .padding(.top, 19)
                    .padding(.bottom, GaiaSpacing.xl)
                }
                .scrollDismissesKeyboard(.interactively)
                .padding(.top, topBarHeight)
                .padding(.bottom, bottomBarHeight)

                VStack(spacing: 0) {
                    ObserveDetailsToolbar(
                        topPadding: toolbarTopPadding,
                        onBack: onBack,
                        onSave: onContinue
                    )

                    Spacer(minLength: 0)

                    ObserveBottomActionBar(
                        bottomInset: bottomSafeInset,
                        action: onContinue
                    )
                }
            }
        }
        .fullScreenCover(isPresented: $showsExpandedMap) {
            ObserveMapExpandedScreen(observation: draftObservation) {
                showsExpandedMap = false
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private var windowSafeBottomInset: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .safeAreaInsets.bottom ?? 0
    }
}

private struct ObserveDetailsToolbar: View {
    let topPadding: CGFloat
    let onBack: () -> Void
    let onSave: () -> Void

    var body: some View {
        HStack(spacing: GaiaSpacing.pillHorizontal) {
            ToolbarGlassButton(icon: .back, accessibilityLabel: "Back", action: onBack)

            Text("Details")
                .gaiaFont(.title1Medium)
                .foregroundStyle(GaiaColor.oliveGreen500)
                .frame(maxWidth: .infinity)

            Button(action: onSave) {
                Text("Save")
                    .gaiaFont(.footnote)
                    .foregroundStyle(GaiaColor.broccoliBrown400)
                    .frame(width: 48, alignment: .trailing)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, GaiaSpacing.md)
        .padding(.top, topPadding)
        .padding(.bottom, GaiaSpacing.md)
        .frame(maxWidth: .infinity)
        .background(GaiaColor.paperWhite50)
        .shadow(color: GaiaShadow.mdColor, radius: GaiaShadow.mdRadius, x: 0, y: GaiaShadow.mdYOffset)
    }
}

private struct ObserveBottomActionBar: View {
    let bottomInset: CGFloat
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: action) {
                Text("Save Find")
                    .gaiaFont(.bodyBold)
                    .foregroundStyle(GaiaColor.paperWhite50)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        Capsule(style: .continuous)
                            .fill(GaiaColor.oliveGreen500)
                    )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, GaiaSpacing.md + 4)
            .padding(.top, GaiaSpacing.md)
            .padding(.bottom, max(GaiaSpacing.md, bottomInset))
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .shadow(color: GaiaShadow.lgColor, radius: GaiaShadow.lgRadius, x: 0, y: GaiaShadow.lgYOffset)
    }
}

private struct ObserveDetailsPhotoStrip: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: GaiaSpacing.sm) {
                ObserveCapturedPhotoCard(
                    imageName: "observe-photo-highlight",
                    width: ObserveDetailsLayout.highlightCardWidth,
                    isHighlight: true
                )

                ObserveCapturedPhotoCard(
                    imageName: "observe-photo-square",
                    width: ObserveDetailsLayout.squareCardWidth
                )

                ObserveCapturedPhotoCard(
                    imageName: "observe-photo-portrait",
                    width: ObserveDetailsLayout.portraitCardWidth
                )

                Button(action: {}) {
                    ZStack {
                        RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                            .fill(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                                    .stroke(GaiaColor.inkBlack300, lineWidth: 1)
                            )

                        GaiaIcon(kind: .plus, size: 24, tint: GaiaColor.inkBlack300)
                    }
                    .frame(width: ObserveDetailsLayout.addCardWidth, height: ObserveDetailsLayout.photoCardHeight)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add photo")
            }
            .scrollTargetLayout()
        }
        .frame(height: ObserveDetailsLayout.photoCardHeight)
        .frame(maxWidth: .infinity, alignment: .leading)
        .defaultScrollAnchor(.leading)
        .scrollTargetBehavior(.viewAligned)
    }
}

private struct ObserveCapturedPhotoCard: View {
    let imageName: String
    let width: CGFloat
    var isHighlight: Bool = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            GaiaAssetImage(name: imageName)
                .frame(width: width, height: ObserveDetailsLayout.photoCardHeight)
                .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 1)
                )

            Button(action: {}) {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.1))
                    GaiaIcon(kind: .close, size: 12, tint: Color.white.opacity(0.95))
                }
                .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            .padding(7)
            .accessibilityLabel("Remove photo")

            if isHighlight {
                Text("Highlight")
                    .gaiaFont(.caption)
                    .foregroundStyle(GaiaColor.paperWhite50)
                    .padding(.horizontal, GaiaSpacing.pillHorizontal)
                    .padding(.vertical, 3)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.black.opacity(0.5))
                            .overlay(
                                Capsule(style: .continuous)
                                    .stroke(GaiaColor.blackishGrey200.opacity(0.8), lineWidth: 0.5)
                            )
                    )
                    .padding(GaiaSpacing.pillHorizontal)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .allowsHitTesting(false)
            }
        }
        .frame(width: width, height: ObserveDetailsLayout.photoCardHeight)
    }
}

private struct ObserveDetailsSectionTitle: View {
    let title: String

    var body: some View {
        Text(title)
            .gaiaFont(.title3)
            .foregroundStyle(GaiaColor.inkBlack300)
    }
}

private struct ObserveIdentificationCard: View {
    var body: some View {
        Button(action: {}) {
            HStack(spacing: GaiaSpacing.cardInset) {
                GaiaAssetImage(name: "observe-suggestion-top")
                    .frame(width: 82, height: 82)
                    .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                            .stroke(GaiaColor.oliveGreen500, lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: GaiaSpacing.cardInset) {
                    Text("Coast Live Oak")
                        .gaiaFont(.title2Medium)
                        .foregroundStyle(GaiaColor.oliveGreen500)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)

                    Text("Quercus agrifolia (94%)")
                        .gaiaFont(.footnote)
                        .foregroundStyle(GaiaColor.blackishGrey500)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ObserveChevronIcon(size: 32)
            }
            .padding(GaiaSpacing.cardInset)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                            .stroke(GaiaColor.broccoliBrown200, lineWidth: 1)
                    )
            )
            .shadow(color: GaiaColor.grassGreen500.opacity(0.23), radius: 13, x: 0, y: 6)
            .shadow(color: GaiaColor.grassGreen500.opacity(0.12), radius: 24, x: 0, y: 24)
        }
        .buttonStyle(.plain)
    }
}

private struct ObserveNotesField: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 1)
                )

            TextEditor(text: $text)
                .gaiaFont(.subheadline)
                .foregroundStyle(GaiaColor.textPrimary)
                .padding(.horizontal, GaiaSpacing.sm)
                .padding(.vertical, 6)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .focused($isFocused)
                .textInputAutocapitalization(.sentences)
                .accessibilityLabel("Add notes")

            if text.isEmpty {
                Text("Add find notes...")
                    .gaiaFont(.footnote)
                    .foregroundStyle(GaiaColor.broccoliBrown400)
                    .padding(.horizontal, GaiaSpacing.md - 4)
                    .padding(.vertical, GaiaSpacing.md - 4)
                    .allowsHitTesting(false)
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
        .onTapGesture {
            isFocused = true
        }
        .frame(maxWidth: .infinity)
        .frame(height: ObserveDetailsLayout.notesHeight)
    }
}

private struct ObserveMapDataCard: View {
    let observation: Observation
    let onExpandMap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                GaiaAssetImage(name: "observe-map-preview", contentMode: .fill)

                MapAnnotationPhotoPin(imageName: observation.thumbnailAssetName)
                    .frame(width: 63, height: 63)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .allowsHitTesting(false)
            }
                .overlay(alignment: .topTrailing) {
                    ExpandMapButton(action: onExpandMap)
                        .padding(GaiaSpacing.cardInset)
                }
                .frame(height: ObserveDetailsLayout.mapHeight)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 1)
                )
                .padding(.top, GaiaSpacing.md - 4)

            VStack(spacing: 0) {
                ObserveMapLocationRow()
                ObserveMapRowDivider()
                ObserveSimpleMapRow(text: "Mar 22, 2026 · 10:53 PM PT", color: GaiaColor.blackishGrey600)
                ObserveMapRowDivider()
                ObserveGeoPrivacyRow()
            }
            .padding(.horizontal, GaiaSpacing.xxs)
            .padding(.top, GaiaSpacing.xxs)
        }
        .padding(.horizontal, GaiaSpacing.md - 4)
        .padding(.bottom, GaiaSpacing.md - 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 1)
                )
        )
        .shadow(color: GaiaShadow.mdColor, radius: GaiaShadow.mdRadius, x: 0, y: GaiaShadow.mdYOffset)
    }
}

private struct ObserveMapLocationRow: View {
    var body: some View {
        HStack(spacing: GaiaSpacing.sm) {
            VStack(alignment: .leading, spacing: GaiaSpacing.xs) {
                HStack(spacing: GaiaSpacing.xs) {
                    GaiaAssetImage(name: "Icons/System/pin-20.png", contentMode: .fit)
                        .frame(width: 10, height: 21)
                        .opacity(0.48)

                    Text("E Del Mar, Pasadena, California")
                        .gaiaFont(.subheadline)
                        .foregroundStyle(GaiaColor.blackishGrey700)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                Text("34.14, -118.14 · 9m accuracy")
                    .gaiaFont(.caption)
                    .foregroundStyle(GaiaColor.blackishGrey200)
                    .lineLimit(1)
            }

            Spacer(minLength: GaiaSpacing.sm)

            ObserveRowChevron()
        }
        .frame(height: 71)
    }
}

private struct ObserveSimpleMapRow: View {
    let text: String
    let color: Color

    var body: some View {
        HStack {
            Text(text)
                .gaiaFont(.subheadline)
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer(minLength: GaiaSpacing.sm)
            ObserveRowChevron()
        }
        .frame(height: 71)
    }
}

private struct ObserveGeoPrivacyRow: View {
    var body: some View {
        HStack(spacing: GaiaSpacing.md - 4) {
            HStack(spacing: GaiaSpacing.xs) {
                ObserveGlobeIcon()
                Text("Geoprivacy")
                    .gaiaFont(.subheadline)
                    .foregroundStyle(GaiaColor.blackishGrey700)
            }

            Spacer(minLength: GaiaSpacing.sm)

            Text("Open")
                .gaiaFont(.body)
                .foregroundStyle(GaiaColor.oliveGreen500)
                .padding(.horizontal, GaiaSpacing.md)
                .frame(height: 32)
                .background(
                    Capsule(style: .continuous)
                        .fill(GaiaColor.paperWhite50)
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(GaiaColor.oliveGreen500, lineWidth: 0.8)
                        )
                )

            ObserveRowChevron()
        }
        .frame(height: 71)
    }
}

private struct ObserveMapRowDivider: View {
    var body: some View {
        Rectangle()
            .fill(GaiaColor.broccoliBrown200)
            .frame(height: 1)
            .frame(maxWidth: .infinity)
    }
}

private struct ObserveRowChevron: View {
    var body: some View {
        ObserveChevronIcon(size: 20)
    }
}

private struct ObserveMetadataCard: View {
    var body: some View {
        VStack(spacing: 0) {
            ObserveMetadataRow(
                icon: "leaf.fill",
                title: "Captured",
                value: "N/A",
                valueStyle: .pill
            )
            ObserveMapRowDivider()
            ObserveMetadataRow(
                icon: "folder.fill",
                title: "Projects",
                value: "None",
                valueStyle: .plain
            )
        }
        .padding(.horizontal, GaiaSpacing.md - 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 1)
                )
        )
        .shadow(color: GaiaShadow.mdColor, radius: GaiaShadow.mdRadius, x: 0, y: GaiaShadow.mdYOffset)
    }
}

private struct ObserveMetadataRow: View {
    enum ValueStyle {
        case pill
        case plain
    }

    let icon: String
    let title: String
    let value: String
    let valueStyle: ValueStyle

    var body: some View {
        HStack(spacing: GaiaSpacing.md - 4) {
            RoundedRectangle(cornerRadius: GaiaRadius.thumbnail, style: .continuous)
                .fill(GaiaColor.broccoliBrown50)
                .frame(width: 24, height: 24)
                .overlay(
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .foregroundStyle(GaiaColor.broccoliBrown500)
                )

            Text(title)
                .gaiaFont(.subheadline)
                .foregroundStyle(GaiaColor.blackishGrey700)

            Spacer(minLength: GaiaSpacing.sm)

            switch valueStyle {
            case .pill:
                Text(value)
                    .gaiaFont(.body)
                    .foregroundStyle(GaiaColor.oliveGreen500)
                    .padding(.horizontal, GaiaSpacing.md)
                    .frame(height: 32)
                    .background(
                        Capsule(style: .continuous)
                            .fill(GaiaColor.paperWhite50)
                            .overlay(
                                Capsule(style: .continuous)
                                    .stroke(GaiaColor.oliveGreen500, lineWidth: 0.8)
                            )
                    )
            case .plain:
                Text(value)
                    .gaiaFont(.body)
                    .foregroundStyle(GaiaColor.broccoliBrown500)
            }

            ObserveRowChevron()
        }
        .frame(height: 71)
    }
}

private struct ObserveConditionCard: View {
    let label: String
    let title: String
    let subtitle: String
    let showsActionIcon: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
            Text(label)
                .gaiaFont(.caption)
                .foregroundStyle(GaiaColor.broccoliBrown500)

            VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                Text(title)
                    .gaiaFont(.body)
                    .foregroundStyle(GaiaColor.textPrimary)
                    .lineLimit(1)

                Text(subtitle)
                    .gaiaFont(.caption)
                    .foregroundStyle(GaiaColor.inkBlack200)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(GaiaSpacing.cardInset)
        .frame(width: ObserveDetailsLayout.conditionCardWidth, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 1)
                )
        )
        .overlay(alignment: .bottomTrailing) {
            if showsActionIcon {
                GaiaIcon(kind: .circleArrowRight, size: 16)
                    .padding(GaiaSpacing.md - 4)
                    .accessibilityHidden(true)
            }
        }
    }
}

private struct ObserveChevronIcon: View {
    let size: CGFloat

    var body: some View {
        Group {
            if let chevron = AssetCatalog.image(named: "Icons/System/chevron-20.png") {
                chevron
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .foregroundStyle(GaiaColor.blackishGrey300)
            } else {
                Image(systemName: "chevron.right")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(GaiaColor.blackishGrey300)
            }
        }
        .frame(width: vectorSize.width, height: vectorSize.height)
        .rotationEffect(.degrees(90))
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }

    private var vectorSize: CGSize {
        switch size {
        case 32:
            return CGSize(width: 21.5, height: 11.086)
        default:
            return CGSize(width: 13.437, height: 6.929)
        }
    }
}

private struct ObserveGlobeIcon: View {
    var body: some View {
        Group {
            if let globe = AssetCatalog.image(named: "Icons/System/globe-24.png") {
                globe
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .foregroundStyle(GaiaColor.blackishGrey700)
            } else {
                Image(systemName: "globe")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(GaiaColor.blackishGrey700)
            }
        }
        .frame(width: 24, height: 24)
        .accessibilityHidden(true)
    }
}

private struct ObserveMapExpandedScreen: View {
    let observation: Observation
    let dismiss: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            ExploreMapView(
                observations: [observation],
                recenterRequestID: nil,
                onSelectObservation: nil,
                showsMarkers: true,
                initialZoomOverride: 13.0
            )
            .ignoresSafeArea()

            ToolbarGlassButton(icon: .back, accessibilityLabel: "Back", action: dismiss)
                .padding(.leading, GaiaSpacing.md)
                .safeAreaPadding(.top, 8)
        }
    }
}

private extension Color {
    init(hex: UInt) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}
