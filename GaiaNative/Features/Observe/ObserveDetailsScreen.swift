// figma: https://www.figma.com/design/X0NcuRE0WKmsqR36cvlcij/Write-Test-Pro?node-id=16-2465 (Log Details 1), 16-2491 (Log Details 2), 16-2502 (Log Details 3)
import SwiftUI

private enum ObserveDetailsLayout {
    static let toolbarButtonSize: CGFloat = 48
    static let photoCardHeight: CGFloat = 138
    static let highlightCardWidth: CGFloat = 223
    static let squareCardWidth: CGFloat = 138
    static let portraitCardWidth: CGFloat = 104
    static let addCardWidth: CGFloat = 74
    static let photoCardCornerRadius: CGFloat = 9.867
    static let notesHeight: CGFloat = 125
    static let mapHeight: CGFloat = 214
    static let actionButtonHeight: CGFloat = 50
    static let contentCardWidth: CGFloat = 181
    static let mapRowHeight: CGFloat = 58
    static let suggestionHeroHeight: CGFloat = 228.95
    static let suggestionRowHeight: CGFloat = 104
    static let suggestionThumbSize: CGFloat = 76
}

struct ObserveDetailsScreen: View {
    let onBack: () -> Void
    let onContinue: () -> Void

    @State private var notesText = ""
    @State private var showsExpandedMap = false
    @State private var showsSuggestionPicker = false
    @State private var selectedSuggestion = ObserveSpeciesSuggestion.leatherback
    @State private var hasConfirmedSuggestion = false

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
                        ObserveDetailsPhotoStrip(assets: currentAssets)

                        VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                            ObserveDetailsSectionTitle(title: "Identification")
                            ObserveIdentificationCard(
                                thumbnailAssetName: currentAssets.identificationThumbnailName,
                                onTap: { showsSuggestionPicker = true }
                            )
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
                            ObserveDetailsSectionTitle(title: "Condition")

                            HStack(spacing: GaiaSpacing.sm) {
                                ObserveConditionCard(
                                    kind: .biome,
                                    label: "Biome",
                                    title: "Tropical Marine",
                                    subtitle: "Hawai'i North Shore"
                                )
                                ObserveConditionCard(
                                    kind: .weather,
                                    label: "Weather",
                                    title: "Partly Cloudy",
                                    subtitle: "July 10, 2025, 10:19 AM"
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
                        title: "Details",
                        topPadding: toolbarTopPadding,
                        onBack: onBack,
                        onSave: onContinue,
                        isSaveEnabled: hasConfirmedSuggestion
                    )

                    Spacer(minLength: 0)

                    ObserveBottomActionBar(
                        bottomInset: bottomSafeInset,
                        isEnabled: hasConfirmedSuggestion,
                        action: onContinue
                    )
                }
            }
        }
        .fullScreenCover(isPresented: $showsSuggestionPicker) {
            ObserveIdentificationSuggestionsScreen(
                selectedSuggestion: selectedSuggestion,
                onBack: {
                    showsSuggestionPicker = false
                },
                onSelectSuggestion: { suggestion in
                    selectedSuggestion = suggestion
                    hasConfirmedSuggestion = true
                    showsSuggestionPicker = false
                }
            )
        }
        .fullScreenCover(isPresented: $showsExpandedMap) {
            ObserveMapExpandedScreen(observation: draftObservation) {
                showsExpandedMap = false
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private var currentAssets: ObserveDetailsAssetSet {
        hasConfirmedSuggestion ? .postselect : .preselect
    }

    private var draftObservation: Observation {
        Observation(
            id: "observe-draft-1",
            speciesID: "observe-draft",
            latitude: 21.619013,
            longitude: -158.0852312,
            thumbnailAssetName: currentAssets.highlightImageName
        )
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
    let title: String
    let topPadding: CGFloat
    let onBack: () -> Void
    let onSave: (() -> Void)?
    let isSaveEnabled: Bool

    var body: some View {
        HStack(spacing: 10) {
            ToolbarGlassButton(icon: .back, accessibilityLabel: "Back", action: onBack)

            Text(title)
                .gaiaFont(.title1Medium)
                .foregroundStyle(GaiaColor.oliveGreen500)
                .frame(maxWidth: .infinity)

            Button(action: { onSave?() }) {
                Text("Save")
                    .gaiaFont(.footnote)
                    .foregroundStyle(GaiaColor.broccoliBrown400)
                    .frame(width: 48, alignment: .trailing)
            }
            .disabled(onSave == nil || !isSaveEnabled)
            .buttonStyle(.plain)
            .opacity(onSave == nil || isSaveEnabled ? 1 : 0.85)
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
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: action) {
                Text("Save Find")
                    .gaiaFont(.body)
                    .foregroundStyle(isEnabled ? GaiaColor.paperWhite50 : GaiaColor.blackishGrey200)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        Capsule(style: .continuous)
                            .fill(isEnabled ? GaiaColor.oliveGreen500 : GaiaColor.blackishGrey200.opacity(0.2))
                    )
            }
            .disabled(!isEnabled)
            .buttonStyle(.plain)
            .padding(.horizontal, GaiaSpacing.md + 4)
            .padding(.top, GaiaSpacing.md)
            .padding(.bottom, max(GaiaSpacing.md, bottomInset))
        }
        .frame(maxWidth: .infinity)
        .background(GaiaColor.paperWhite50)
        .shadow(color: GaiaShadow.lgColor, radius: GaiaShadow.lgRadius, x: 0, y: GaiaShadow.lgYOffset)
    }
}

private struct ObserveDetailsAssetSet {
    let highlightImageName: String
    let squareImageName: String
    let portraitImageName: String
    let identificationThumbnailName: String

    static let preselect = ObserveDetailsAssetSet(
        highlightImageName: "observe-details-preselect-highlight",
        squareImageName: "observe-details-preselect-square",
        portraitImageName: "observe-details-preselect-portrait",
        identificationThumbnailName: "observe-details-preselect-identification"
    )

    static let postselect = ObserveDetailsAssetSet(
        highlightImageName: "observe-details-postselect-highlight",
        squareImageName: "observe-details-postselect-square",
        portraitImageName: "observe-details-postselect-portrait",
        identificationThumbnailName: "observe-details-postselect-identification"
    )
}

private struct ObserveDetailsPhotoStrip: View {
    let assets: ObserveDetailsAssetSet

    var body: some View {
        HStack(spacing: GaiaSpacing.sm) {
            ObserveCapturedPhotoCard(
                imageName: assets.highlightImageName,
                width: ObserveDetailsLayout.highlightCardWidth,
                isHighlight: true
            )

            ObserveCapturedPhotoCard(
                imageName: assets.squareImageName,
                width: ObserveDetailsLayout.squareCardWidth
            )

            ObserveCapturedPhotoCard(
                imageName: assets.portraitImageName,
                width: ObserveDetailsLayout.portraitCardWidth
            )

            Button(action: {}) {
                ZStack {
                    RoundedRectangle(cornerRadius: ObserveDetailsLayout.photoCardCornerRadius, style: .continuous)
                        .fill(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: ObserveDetailsLayout.photoCardCornerRadius, style: .continuous)
                                .stroke(GaiaColor.inkBlack300, lineWidth: 1)
                        )

                    GaiaIcon(kind: .plus, size: 24, tint: GaiaColor.inkBlack300)
                }
                .frame(width: ObserveDetailsLayout.addCardWidth, height: ObserveDetailsLayout.photoCardHeight)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Add photo")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipped()
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
                .clipShape(RoundedRectangle(cornerRadius: ObserveDetailsLayout.photoCardCornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: ObserveDetailsLayout.photoCardCornerRadius, style: .continuous)
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 1)
                )

            Button(action: {}) {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.1))
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.95))
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
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(Color.black.opacity(0.5), in: Capsule())
                    .padding(10)
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
            .gaiaFont(.titleSans)
            .foregroundStyle(GaiaColor.inkBlack300)
    }
}

private struct ObserveIdentificationCard: View {
    let thumbnailAssetName: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: GaiaSpacing.md - 4) {
                GaiaAssetImage(name: thumbnailAssetName)
                    .frame(width: 82, height: 82)
                    .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                            .stroke(GaiaColor.broccoliBrown200, lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                    Text("Coast\nLive Oak")
                        .gaiaFont(.title2Medium)
                        .foregroundStyle(GaiaColor.oliveGreen500)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)

                    Text("Quercus agrifolia (94%)")
                        .gaiaFont(.footnote)
                        .foregroundStyle(GaiaColor.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                GaiaIcon(kind: .circleArrowRight, size: 32)
                    .frame(width: 32, height: 32)
            }
            .padding(GaiaSpacing.md - 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                    .fill(GaiaColor.paperWhite50)
                    .overlay(
                        RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                            .stroke(GaiaColor.broccoliBrown200, lineWidth: 1)
                    )
            )
            .shadow(color: GaiaShadow.mdColor, radius: GaiaShadow.mdRadius, x: 0, y: GaiaShadow.mdYOffset)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Coast Live Oak, Quercus agrifolia, 94 percent match")
        .accessibilityHint("Opens top suggestions")
    }
}

private struct ObserveIdentificationSuggestionsScreen: View {
    let selectedSuggestion: ObserveSpeciesSuggestion
    let onBack: () -> Void
    let onSelectSuggestion: (ObserveSpeciesSuggestion) -> Void

    var body: some View {
        GeometryReader { proxy in
            let toolbarTopPadding = min(max(19, proxy.safeAreaInsets.top + 4), 51)
            let topBarHeight = toolbarTopPadding + ObserveDetailsLayout.toolbarButtonSize + GaiaSpacing.md
            let contentWidth = max(0, proxy.size.width - (GaiaSpacing.md * 2))

            ZStack(alignment: .top) {
                GaiaColor.paperWhite50.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: GaiaSpacing.xl) {
                        GaiaAssetImage(name: ObserveDetailsAssetSet.preselect.highlightImageName, contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .frame(height: ObserveDetailsLayout.suggestionHeroHeight)
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: ObserveDetailsLayout.photoCardCornerRadius,
                                    style: .continuous
                                )
                            )
                            .overlay(
                                RoundedRectangle(
                                    cornerRadius: ObserveDetailsLayout.photoCardCornerRadius,
                                    style: .continuous
                                )
                                .stroke(GaiaColor.broccoliBrown200, lineWidth: 1)
                            )

                        VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                            ObserveDetailsSectionTitle(title: "Top Suggestions")

                            VStack(spacing: 0) {
                                ForEach(ObserveSpeciesSuggestion.allSuggestions) { suggestion in
                                    ObserveSuggestionRow(
                                        suggestion: suggestion,
                                        isSelected: suggestion.id == selectedSuggestion.id,
                                        action: { onSelectSuggestion(suggestion) }
                                    )
                                }
                            }
                            .overlay(alignment: .top) {
                                Rectangle()
                                    .fill(GaiaColor.broccoliBrown200)
                                    .frame(height: 0.5)
                            }
                        }
                    }
                    .frame(width: contentWidth, alignment: .leading)
                    .padding(.horizontal, GaiaSpacing.md)
                    .padding(.top, 24)
                    .padding(.bottom, GaiaSpacing.xxxl)
                }
                .scrollDismissesKeyboard(.interactively)
                .padding(.top, topBarHeight)

                VStack(spacing: 0) {
                    ObserveDetailsToolbar(
                        title: "Details",
                        topPadding: toolbarTopPadding,
                        onBack: onBack,
                        onSave: {},
                        isSaveEnabled: false
                    )

                    Spacer(minLength: 0)
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

private struct ObserveSuggestionRow: View {
    let suggestion: ObserveSpeciesSuggestion
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                GaiaAssetImage(name: suggestion.imageName)
                    .frame(width: ObserveDetailsLayout.suggestionThumbSize, height: ObserveDetailsLayout.suggestionThumbSize)
                    .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))

                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(suggestion.commonName)
                            .gaiaFont(.titleSans)
                            .foregroundStyle(GaiaColor.textPrimary)
                            .lineLimit(2)

                        Text(suggestion.scientificName)
                            .gaiaFont(.footnote)
                            .italic()
                            .foregroundStyle(GaiaColor.broccoliBrown500)
                            .lineLimit(1)
                    }

                    Text(suggestion.metaLabel)
                        .gaiaFont(.caption2)
                        .foregroundStyle(GaiaColor.blackishGrey200)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                GaiaIcon(kind: .circleArrowRight, size: 32)
                    .frame(width: 32, height: 32)
            }
            .padding(.horizontal, GaiaSpacing.md)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, minHeight: ObserveDetailsLayout.suggestionRowHeight, alignment: .leading)
            .background(GaiaColor.paperWhite50)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(GaiaColor.broccoliBrown200)
                    .frame(height: 0.5)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(suggestion.commonName), \(suggestion.scientificName)")
    }
}

private struct ObserveSpeciesSuggestion: Identifiable, Hashable {
    let id: String
    let commonName: String
    let scientificName: String
    let metaLabel: String
    let imageName: String

    static let leatherback = ObserveSpeciesSuggestion(
        id: "leatherback",
        commonName: "Leatherback Sea Turtle",
        scientificName: "Dermochelys coriacea",
        metaLabel: "Visually Similar / Expected Nearby",
        imageName: "observe-suggestion-top"
    )

    static let loggerhead = ObserveSpeciesSuggestion(
        id: "loggerhead",
        commonName: "Loggerhead Sea Turtle",
        scientificName: "Caretta caretta",
        metaLabel: "Visually Similar / Expected Nearby",
        imageName: "observe-suggestion-secondary-1"
    )

    static let flatback = ObserveSpeciesSuggestion(
        id: "flatback",
        commonName: "Flatback Sea Turtle",
        scientificName: "Natator depressus",
        metaLabel: "Visually Similar / Expected Nearby",
        imageName: "observe-suggestion-secondary-2"
    )

    static let allSuggestions: [ObserveSpeciesSuggestion] = [
        .leatherback,
        .loggerhead,
        .flatback
    ]
}

private struct ObserveNotesField: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 1)
                )

            TextEditor(text: $text)
                .gaiaFont(.subheadline)
                .foregroundStyle(GaiaColor.textPrimary)
                .padding(.horizontal, 8)
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
        .contentShape(RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous))
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
                ExploreMapView(
                    observations: [observation],
                    recenterRequestID: nil,
                    onSelectObservation: nil,
                    showsMarkers: false,
                    initialZoomOverride: 13.0
                )
                .allowsHitTesting(false)

                MapAnnotationPhotoPin(imageName: observation.thumbnailAssetName)
                    .frame(width: 63, height: 63)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .allowsHitTesting(false)
            }
            .overlay(alignment: .topTrailing) {
                ExpandMapButton(action: onExpandMap)
                    .padding(12)
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
            .padding(.horizontal, 2)
            .padding(.top, 2)
        }
        .padding(.horizontal, GaiaSpacing.md - 4)
        .padding(.bottom, GaiaSpacing.md - 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
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

                    Text("Pohaku Loa Way, Haleiwa, Hawaii")
                        .gaiaFont(.subheadline)
                        .foregroundStyle(GaiaColor.blackishGrey700)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                Text("21.619013, -158.0852312 · 9m accuracy")
                    .gaiaFont(.caption)
                    .foregroundStyle(GaiaColor.blackishGrey200)
                    .lineLimit(1)
            }

            Spacer(minLength: GaiaSpacing.sm)

            ObserveRowChevron()
        }
        .frame(height: ObserveDetailsLayout.mapRowHeight)
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
        .frame(height: ObserveDetailsLayout.mapRowHeight)
    }
}

private struct ObserveGeoPrivacyRow: View {
    var body: some View {
        HStack(spacing: GaiaSpacing.md - 4) {
            HStack(spacing: GaiaSpacing.xs) {
                Image(systemName: "globe")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(GaiaColor.blackishGrey700)
                    .frame(width: 24, height: 24)
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
        .frame(height: ObserveDetailsLayout.mapRowHeight)
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
        Group {
            if let chevron = AssetCatalog.image(named: "Icons/System/chevron-20.png") {
                chevron
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(GaiaColor.blackishGrey300)
            } else {
                Image(systemName: "chevron.right")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(GaiaColor.blackishGrey300)
            }
        }
        .frame(width: 20, height: 20)
        .accessibilityHidden(true)
    }
}

private struct ObserveMetadataCard: View {
    var body: some View {
        VStack(spacing: 0) {
            ObserveMetadataRow(
                title: "Captured",
                value: "N/A",
                valueStyle: .pillDisabled
            )
            ObserveMapRowDivider()
            ObserveMetadataRow(
                title: "Projects",
                value: "N/A",
                valueStyle: .pillDisabled
            )
        }
        .padding(.horizontal, GaiaSpacing.md - 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 1)
                )
        )
        .shadow(color: GaiaShadow.mdColor, radius: GaiaShadow.mdRadius, x: 0, y: GaiaShadow.mdYOffset)
    }
}

private struct ObserveMetadataRow: View {
    enum ValueStyle {
        case pillDisabled
    }

    let title: String
    let value: String
    let valueStyle: ValueStyle

    var body: some View {
        HStack(spacing: GaiaSpacing.md - 4) {
            Circle()
                .fill(Color(hex: 0xF3F0E6))
                .frame(width: 24, height: 24)

            Text(title)
                .gaiaFont(.subheadline)
                .foregroundStyle(GaiaColor.blackishGrey700)

            Spacer(minLength: GaiaSpacing.sm)

            switch valueStyle {
            case .pillDisabled:
                Text(value)
                    .gaiaFont(.body)
                    .foregroundStyle(GaiaColor.blackishGrey200)
                    .padding(.horizontal, GaiaSpacing.md)
                    .frame(height: 34)
                    .background(
                        Capsule(style: .continuous)
                            .fill(GaiaColor.blackishGrey200.opacity(0.2))
                    )
            }

            ObserveRowChevron()
        }
        .frame(height: ObserveDetailsLayout.mapRowHeight)
    }
}

private struct ObserveConditionCard: View {
    enum Kind {
        case biome
        case weather
    }

    let kind: Kind
    let label: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
            ObserveConditionHero(kind: kind)

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
        .padding(GaiaSpacing.md - 4)
        .frame(width: ObserveDetailsLayout.contentCardWidth, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 1)
                )
        )
        .overlay(alignment: .bottomTrailing) {
            GaiaIcon(kind: .circleArrowRight, size: 20)
                .padding(GaiaSpacing.md - 4)
                .accessibilityHidden(true)
        }
    }
}

private struct ObserveConditionHero: View {
    let kind: ObserveConditionCard.Kind

    var body: some View {
        ZStack(alignment: .leading) {
            switch kind {
            case .biome:
                LinearGradient(
                    colors: [
                        Color(hex: 0xE8DDC3),
                        Color(hex: 0xA1B39A),
                        Color(hex: 0x6C8264)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay(
                    RadialGradient(
                        colors: [Color.white.opacity(0.35), .clear],
                        center: .topLeading,
                        startRadius: 10,
                        endRadius: 80
                    )
                )
            case .weather:
                LinearGradient(
                    colors: [
                        Color(hex: 0x245A8C),
                        Color(hex: 0x5D84B0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("54º")
                            .gaiaFont(.weatherValue)
                            .foregroundStyle(GaiaColor.paperWhite50)
                            .padding(.trailing, GaiaSpacing.sm)
                    }
                }
                .padding(.bottom, 4)
            }
        }
        .frame(height: 126)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
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
