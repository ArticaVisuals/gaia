// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=1609-176524 (Find Expanded), 1377-100096 (Find Contracted), 1377-100167 (Activity Contracted)
import SwiftUI
import UIKit

private enum FindDetailsPrototypeLayout {
    static let designWidth: CGFloat = 402
    static let expandedHeroHeight: CGFloat = 441
    static let collapsedHeroHeight: CGFloat = 228
    // The hero image bleeds below the static top container so it can fill the
    // panel's rounded top corners. Figma sets the image frame to 487 in expanded
    // and 264 in contracted (the static-top container heights are 441 / 191).
    static let expandedImageHeight: CGFloat = 487
    static let collapsedImageHeight: CGFloat = 264
    static let expandedPanelTop: CGFloat = 428
    static let collapsedPanelTop: CGFloat = 205
    static let tabHeaderHeight: CGFloat = 60
    static let expandedContentOffset: CGFloat = 488
    static let collapsedContentOffset: CGFloat = 265
    static let contentTopPadding: CGFloat = 16
}

private struct FindDetailsPrototypeMetrics {
    let expandedHeroHeight: CGFloat
    let collapsedHeroHeight: CGFloat
    let expandedImageHeight: CGFloat
    let collapsedImageHeight: CGFloat
    let expandedPanelTop: CGFloat
    let collapsedPanelTop: CGFloat
    let tabHeaderHeight: CGFloat
    let collapseDistance: CGFloat
    let collapsedContentOffset: CGFloat
    let expandedContentOffset: CGFloat
    let contentTopPadding: CGFloat

    init(contentWidth: CGFloat) {
        let scale = contentWidth / FindDetailsPrototypeLayout.designWidth
        expandedHeroHeight = FindDetailsPrototypeLayout.expandedHeroHeight * scale
        collapsedHeroHeight = FindDetailsPrototypeLayout.collapsedHeroHeight * scale
        expandedImageHeight = FindDetailsPrototypeLayout.expandedImageHeight * scale
        collapsedImageHeight = FindDetailsPrototypeLayout.collapsedImageHeight * scale
        expandedPanelTop = FindDetailsPrototypeLayout.expandedPanelTop * scale
        collapsedPanelTop = FindDetailsPrototypeLayout.collapsedPanelTop * scale
        tabHeaderHeight = FindDetailsPrototypeLayout.tabHeaderHeight * scale
        contentTopPadding = FindDetailsPrototypeLayout.contentTopPadding * scale
        expandedContentOffset = FindDetailsPrototypeLayout.expandedContentOffset * scale
        collapsedContentOffset = FindDetailsPrototypeLayout.collapsedContentOffset * scale
        collapseDistance = max(1, expandedContentOffset - collapsedContentOffset)
    }
}

struct FindDetailsPrototypeScreen: View {
    let species: Species

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var contentStore: ContentStore

    @State private var selectedTab: FindDetailsTab = .find
    @State private var scrollOffset: CGFloat = 0
    @State private var showsExpandedMap = false
    @State private var showsLearnScreen = false
    @State private var pendingStoryDeckID: String?

    private let mapDataService = MapDataService()

    private var deviceBottomSafeArea: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .safeAreaInsets.bottom ?? 0
    }

    private enum FindMapReference {
        static let latitude = 35.1797
        static let longitude = -120.7361
    }

    private enum ScrollMarker: Hashable {
        case lockPoint
    }

    private enum ScrollCoordinateSpace {
        static let name = "find-details-prototype-scroll"
    }

    var body: some View {
        ScrollViewReader { scrollProxy in
            GeometryReader { proxy in
                let contentWidth = proxy.size.width
                let metrics = FindDetailsPrototypeMetrics(contentWidth: contentWidth)
                let liveCollapseOffset = min(max(scrollOffset, 0), metrics.collapseDistance)
                let collapseOffset = screenshotCollapseOffset(for: metrics, liveCollapseOffset: liveCollapseOffset)
                let collapseProgress = metrics.collapseDistance > 0
                    ? collapseOffset / metrics.collapseDistance
                    : 1
                let usesCollapsedContentLayout = true
                let heroHeight = metrics.expandedHeroHeight + ((metrics.collapsedHeroHeight - metrics.expandedHeroHeight) * collapseProgress)
                let heroImageHeight = metrics.expandedImageHeight + ((metrics.collapsedImageHeight - metrics.expandedImageHeight) * collapseProgress)
                let panelTop = metrics.expandedPanelTop + ((metrics.collapsedPanelTop - metrics.expandedPanelTop) * collapseProgress)
                let contentBottomInset = deviceBottomSafeArea
                // Figma leaves 32pt before the Activity stack; the tab content itself
                // already contributes 12pt, so the outer prototype inset stays at 20pt.
                let activityContentTopPadding = contentWidth * (20 / FindDetailsPrototypeLayout.designWidth)
                let tabContentTopPadding = selectedTab == .activity
                    ? activityContentTopPadding
                    : metrics.contentTopPadding

                ZStack(alignment: .topLeading) {
                    GaiaColor.surfaceSheet.ignoresSafeArea()

                    PrototypePanelSurface()
                        .frame(
                            width: contentWidth,
                            height: proxy.size.height + metrics.expandedContentOffset
                        )
                        .offset(y: panelTop)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            Color.clear
                                .frame(height: 0)
                                .onGeometryChange(for: CGFloat.self) { geometry in
                                    geometry.frame(in: .named(ScrollCoordinateSpace.name)).minY
                                } action: { newValue in
                                    scrollOffset = max(0, -newValue)
                                }

                            if isLockedScreenshotMode {
                                collapsedHeaderSpacer(metrics: metrics, contentWidth: contentWidth)
                            } else {
                                Color.clear
                                    .frame(height: metrics.collapseDistance)
                                    .id(ScrollMarker.lockPoint)

                                collapsedHeaderSpacer(metrics: metrics, contentWidth: contentWidth)
                            }

                            currentTabContent(
                                collapseProgress: collapseProgress,
                                usesCollapsedContentLayout: usesCollapsedContentLayout
                            )
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                                .padding(.top, tabContentTopPadding)
                                .offset(y: screenshotContentShift)

                            if screenshotContentBottomCompensation > 0 {
                                Color.clear
                                    .frame(height: screenshotContentBottomCompensation)
                            }

                            Color.clear
                                .frame(height: contentBottomInset)
                        }
                        .frame(width: contentWidth, alignment: .topLeading)
                    }
                    .coordinateSpace(name: ScrollCoordinateSpace.name)
                    .allowsHitTesting(!isLockedScreenshotMode)

                    FindDetailsPrototypeHero(
                        species: species,
                        collapseProgress: collapseProgress,
                        imageHeight: heroImageHeight,
                        visibleHeight: panelTop,
                        onLearnAction: {
                            HapticsService.selectionChanged()
                            showsLearnScreen = true
                        }
                    )
                    .frame(width: contentWidth, height: heroHeight, alignment: .topLeading)

                    PrototypeTabHeader(selection: $selectedTab)
                        .frame(width: contentWidth, height: metrics.tabHeaderHeight)
                        .offset(y: panelTop)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)

                    PrototypeToolbarOverlay(
                        onBack: { appState.closeFindDetailsPrototype() }
                    )
                    .frame(width: contentWidth, alignment: .top)

                }
            }
        }
        .ignoresSafeArea(edges: [.top, .bottom])
        .statusBarHidden(true)
        .onAppear {
            scrollOffset = 0
            selectedTab = appState.selectedFindTab
            appState.selectedFindTab = selectedTab
            showsLearnScreen = launchArguments.contains("-gaiaFindDetailsPrototypeLearn")
        }
        .onChange(of: selectedTab) { _, newValue in
            if appState.selectedFindTab != newValue {
                appState.selectedFindTab = newValue
            }
        }
        .onChange(of: appState.selectedFindTab) { _, newValue in
            if selectedTab != newValue {
                selectedTab = newValue
            }
        }
        .fullScreenCover(isPresented: $showsExpandedMap) {
            FindMapExpandedScreen(observation: findMapObservation(usesCollapsedContentLayout: false)) {
                showsExpandedMap = false
            }
        }
        .fullScreenCover(
            isPresented: $showsLearnScreen,
            onDismiss: presentPendingStoryDeck
        ) {
            FindDetailsLearnScreen(
                species: species,
                observations: speciesObservations,
                stories: contentStore.stories,
                dismiss: { showsLearnScreen = false },
                onOpenStory: { story in
                    pendingStoryDeckID = story.id
                    showsLearnScreen = false
                }
            )
        }
    }

    private var launchArguments: Set<String> {
        Set(ProcessInfo.processInfo.arguments)
    }

    private var isLockedScreenshotMode: Bool {
        launchArguments.contains("-gaiaFindDetailsPrototypeLocked")
    }

    private var isMidCollapseScreenshotMode: Bool {
        launchArguments.contains("-gaiaFindDetailsPrototypeMidCollapse")
    }

    private var screenshotContentShift: CGFloat {
        guard isLockedScreenshotMode, launchArguments.contains("-gaiaFindDetailsPrototypeLower") else {
            return 0
        }
        if launchArguments.contains("-gaiaFindDetailsPrototypeProjectsDeep") {
            return -760
        }
        if launchArguments.contains("-gaiaFindDetailsPrototypeProjects") {
            return -620
        }
        return -420
    }

    private var screenshotContentBottomCompensation: CGFloat {
        max(0, -screenshotContentShift)
    }

    private func presentPendingStoryDeck() {
        guard let pendingStoryDeckID else { return }
        self.pendingStoryDeckID = nil
        appState.openStoryDeck(pendingStoryDeckID, speciesID: species.id)
    }

    private func screenshotCollapseOffset(
        for metrics: FindDetailsPrototypeMetrics,
        liveCollapseOffset: CGFloat
    ) -> CGFloat {
        if isLockedScreenshotMode {
            return metrics.collapseDistance
        }

        if isMidCollapseScreenshotMode {
            return metrics.collapseDistance * 0.5
        }

        return liveCollapseOffset
    }

    @ViewBuilder
    private func currentTabContent(
        collapseProgress: CGFloat,
        usesCollapsedContentLayout: Bool
    ) -> some View {
        switch selectedTab {
        case .find:
            FindTabView(
                collapseProgress: collapseProgress,
                usesCollapsedContentLayout: usesCollapsedContentLayout,
                photoAssetNames: prototypePhotoAssetNames,
                mapObservation: findMapObservation(usesCollapsedContentLayout: usesCollapsedContentLayout),
                onExpandMap: { showsExpandedMap = true },
                onOpenProject: { project in
                    appState.openProjectDetail(project)
                }
            )
        case .activity:
            ActivityTabView(species: species)
        }
    }

    private var prototypePhotoAssetNames: [String] {
        [
            "coast-live-oak-gallery-1",
            "coast-live-oak-gallery-2",
            "coast-live-oak-gallery-4"
        ]
    }

    private var speciesObservations: [Observation] {
        let filtered = contentStore.observations.filter { $0.speciesID == species.id }
        guard filtered.isEmpty else {
            return mapDataService.expandedObservations(
                from: filtered,
                targetCount: 150,
                seed: "\(species.id)-find-map"
            )
        }

        return [
            Observation(
                id: "\(species.id)-detail-preview",
                speciesID: species.id,
                latitude: species.mapCoordinate.latitude,
                longitude: species.mapCoordinate.longitude,
                thumbnailAssetName: species.galleryAssetNames.first
            )
        ]
    }

    private func findMapObservation(usesCollapsedContentLayout: Bool) -> Observation {
        return Observation(
            id: "\(species.id)-prototype-find-preview",
            speciesID: species.id,
            latitude: FindMapReference.latitude,
            longitude: FindMapReference.longitude,
            thumbnailAssetName: species.galleryAssetNames.first
                ?? contentStore.observations.first(where: { $0.speciesID == species.id })?.thumbnailAssetName
        )
    }

    private func collapsedHeaderSpacer(
        metrics: FindDetailsPrototypeMetrics,
        contentWidth: CGFloat
    ) -> some View {
        VStack(spacing: 0) {
            Color.clear
                .frame(height: metrics.collapsedPanelTop)

            // Keep an in-scroll interactive header aligned under the pinned visual
            // overlay so vertical drags continue to belong to the scroll view.
            PrototypeTabHeader(selection: $selectedTab)
                .frame(width: contentWidth, height: metrics.tabHeaderHeight)
                .opacity(0.001)
        }
    }
}

private func prototypePanelTopShape() -> UnevenRoundedRectangle {
    UnevenRoundedRectangle(
        cornerRadii: .init(
            topLeading: GaiaRadius.xl,
            bottomLeading: 0,
            bottomTrailing: 0,
            topTrailing: GaiaRadius.xl
        ),
        style: .circular
    )
}

private struct PrototypePanelSurface: View {

    var body: some View {
        prototypePanelTopShape()
            .fill(GaiaColor.paperWhite50)
            .overlay {
                prototypePanelTopShape()
                    .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
            }
            .shadow(color: GaiaShadow.mdColor, radius: GaiaShadow.mdRadius, x: 0, y: GaiaShadow.mdYOffset)
            .allowsHitTesting(false)
    }
}

private struct PrototypeTabHeader: View {
    @Binding var selection: FindDetailsTab

    private let visibleTabs: [FindDetailsTab] = [.find, .activity]

    var body: some View {
        GeometryReader { proxy in
            let topPadding = proxy.size.height * (16 / FindDetailsPrototypeLayout.tabHeaderHeight)
            let switchHeight = max(0, proxy.size.height - topPadding)
            let tabWidth = proxy.size.width / CGFloat(max(visibleTabs.count, 1))

            ZStack(alignment: .topLeading) {
                prototypePanelTopShape()
                    .fill(GaiaColor.paperWhite50)
                    .allowsHitTesting(false)

                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: topPadding)

                    ZStack(alignment: .bottomLeading) {
                        Rectangle()
                            .fill(GaiaColor.blackishGrey200)
                            .frame(height: 1)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            .allowsHitTesting(false)

                        Rectangle()
                            .fill(GaiaColor.olive)
                            .frame(width: tabWidth, height: 3)
                            .offset(x: indicatorOffset(tabWidth: tabWidth))
                            .animation(GaiaMotion.spring, value: selectedIndex)
                            .allowsHitTesting(false)

                        HStack(spacing: 0) {
                            ForEach(visibleTabs) { tab in
                                Button {
                                    guard selection != tab else { return }
                                    HapticsService.selectionChanged()
                                    withAnimation(GaiaMotion.spring) {
                                        selection = tab
                                    }
                                } label: {
                                    Text(tab.rawValue)
                                        .gaiaFont(.body)
                                        .foregroundStyle(selection == tab ? GaiaColor.olive : GaiaColor.blackishGrey200)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(height: switchHeight)
                }
            }
            .clipShape(prototypePanelTopShape())
        }
    }

    private var selectedIndex: Int {
        visibleTabs.firstIndex(of: selection == .activity ? .activity : .find) ?? 0
    }

    private func indicatorOffset(tabWidth: CGFloat) -> CGFloat {
        CGFloat(selectedIndex) * tabWidth
    }
}

private struct FindDetailsPrototypeHero: View {
    let species: Species
    let collapseProgress: CGFloat
    let imageHeight: CGFloat
    let visibleHeight: CGFloat
    let onLearnAction: () -> Void

    private enum Layout {
        static let designWidth: CGFloat = 402
        static let heroTextWidth: CGFloat = 301
        // Figma keeps the image frame 59pt below the panel top in both states.
        static let panelArtworkBleed: CGFloat = 59
        static let expandedScientificTop: CGFloat = 289
        static let collapsedScientificTop: CGFloat = 57
        static let expandedTitleTop: CGFloat = 341
        static let collapsedTitleTop: CGFloat = 109
        static let expandedButtonTop: CGFloat = 361
        static let collapsedButtonTop: CGFloat = expandedButtonTop - (expandedScientificTop - collapsedScientificTop)
        static let horizontalInset: CGFloat = 16
        static let learnButtonWidth: CGFloat = 117
        static let expandedTitleHeight: CGFloat = 68
        static let collapsedTitleHeight: CGFloat = 80
        static let scientificHeight: CGFloat = 32
        static let collapsedBlurRadius: CGFloat = 7.25
        static let titleFontSize: CGFloat = 40
        static let titleLineHeight: CGFloat = 40
        static let titleTracking: CGFloat = -0.5
    }

    private var clampedProgress: CGFloat {
        min(max(collapseProgress, 0), 1)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            heroArtwork
                .allowsHitTesting(false)

            heroCopy
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .mask(alignment: .top) {
                    Rectangle()
                        .frame(maxWidth: .infinity)
                        .frame(height: max(0, visibleHeight))
                }
                .allowsHitTesting(false)

            collapseActionButton
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .mask(alignment: .top) {
                    Rectangle()
                        .frame(maxWidth: .infinity)
                        .frame(height: max(0, visibleHeight))
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var heroArtwork: some View {
        GeometryReader { proxy in
            let scale = proxy.size.width / Layout.designWidth
            let artworkHeight = imageHeight
            let artworkRevealHeight = min(
                artworkHeight,
                max(0, visibleHeight + (Layout.panelArtworkBleed * scale))
            )
            let blurRadius = Layout.collapsedBlurRadius * scale * clampedProgress

            ZStack(alignment: .top) {
                if let imageName = species.galleryAssetNames.first {
                    GaiaAssetImage(name: imageName)
                        .frame(width: proxy.size.width, height: artworkHeight)
                        .blur(radius: blurRadius)
                        .overlay { readabilityGradient }
                        .mask(alignment: .top) {
                            Rectangle()
                                .frame(maxWidth: .infinity)
                                .frame(height: artworkRevealHeight)
                        }
                } else {
                    GaiaColor.oliveGreen700
                        .frame(width: proxy.size.width, height: artworkHeight)
                }
            }
        }
    }

    private var heroCopy: some View {
        return GeometryReader { proxy in
            let scale = proxy.size.width / Layout.designWidth
            let horizontalInset = Layout.horizontalInset * scale
            let textWidth = Layout.heroTextWidth * scale
            let scientificTop = interpolate(
                from: Layout.expandedScientificTop * scale,
                to: Layout.collapsedScientificTop * scale
            )
            let titleTop = interpolate(
                from: Layout.expandedTitleTop * scale,
                to: Layout.collapsedTitleTop * scale
            )
            let titleHeight = interpolate(
                from: Layout.expandedTitleHeight * scale,
                to: Layout.collapsedTitleHeight * scale
            )

            ZStack(alignment: .topLeading) {
                scientificLabelView(scale: scale)
                    .frame(width: textWidth, alignment: .leading)
                    .frame(height: Layout.scientificHeight * scale, alignment: .topLeading)
                    .offset(x: horizontalInset, y: scientificTop)
                    .opacity(collapseAccessoryOpacity)

                titleLabelView(scale: scale, targetHeight: titleHeight)
                    .frame(width: textWidth, alignment: .leading)
                    .offset(x: horizontalInset, y: titleTop)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private var collapseActionButton: some View {
        GeometryReader { proxy in
            let scale = proxy.size.width / Layout.designWidth
            let topOffset = interpolate(
                from: Layout.expandedButtonTop * scale,
                to: Layout.collapsedButtonTop * scale
            )

            ToolbarGlassLearnButton(title: "Learn", accessibilityLabel: "Learn", showsShadow: true, action: onLearnAction)
                .accessibilityHint("Opens the Learn details screen")
                .scaleEffect(scale, anchor: .topTrailing)
                .padding(.trailing, Layout.horizontalInset * scale)
                .offset(y: topOffset)
                .opacity(collapseAccessoryOpacity)
                .allowsHitTesting(collapseAccessoryOpacity > 0.01)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
    }

    private var collapseAccessoryOpacity: CGFloat {
        max(0, 1 - min(clampedProgress * 1.55, 1))
    }

    private func interpolate(from start: CGFloat, to end: CGFloat) -> CGFloat {
        start + ((end - start) * clampedProgress)
    }

    private func scientificLabelView(scale: CGFloat) -> some View {
        Text(multilineScientificName)
            .font(GaiaTypography.scientificLabel)
            .tracking(GaiaTextStyle.scientificLabel.tracking * scale)
            .lineSpacing(GaiaTextStyle.scientificLabel.lineSpacing * scale)
            .foregroundStyle(GaiaColor.paperWhite50)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func titleLabelView(scale: CGFloat, targetHeight: CGFloat) -> some View {
        let fontSize = Layout.titleFontSize * scale
        let tracking = GaiaTextStyle.heroFindExpanded.tracking * scale
        let lineBoxHeight = Layout.titleLineHeight * scale

        return VStack(alignment: .leading, spacing: 0) {
            ForEach(commonNameLines.indices, id: \.self) { index in
                Text(commonNameLines[index])
                    .font(resolvedHeroTitleFont(size: fontSize))
                    .tracking(tracking)
                    .foregroundStyle(GaiaColor.paperWhite50)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, minHeight: lineBoxHeight, maxHeight: lineBoxHeight, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: targetHeight, alignment: .center)
    }

    private var heroReadabilityStops: [Gradient.Stop] {
        [
            .init(color: .clear, location: 0),
            .init(color: .clear, location: 0.3322),
            .init(color: Color.black.opacity(0.65), location: 1)
        ]
    }

    private var readabilityGradient: some View {
        LinearGradient(
            stops: heroReadabilityStops,
            startPoint: .top,
            endPoint: .bottom
        )
        .allowsHitTesting(false)
    }

    private var commonNameLines: [String] {
        let parts = species.commonName.split(separator: " ").map(String.init)
        guard parts.count > 1 else { return [species.commonName] }
        return [parts[0], parts.dropFirst().joined(separator: " ")]
    }

    private var scientificNameLines: [String] {
        let parts = species.scientificName.uppercased().split(separator: " ", maxSplits: 1).map(String.init)
        guard parts.count == 2 else { return [species.scientificName.uppercased()] }
        return parts
    }

    private var multilineScientificName: String {
        scientificNameLines.joined(separator: "\n")
    }

    private func resolvedHeroTitleFont(size: CGFloat) -> Font {
        if let resolvedName = resolvedHeroTitleFontName(size: size) {
            return .custom(resolvedName, size: size)
        }
        return .system(size: size, weight: .medium, design: .serif)
    }

    private func resolvedHeroTitleFontName(size: CGFloat) -> String? {
        if UIFont(name: "NewSpirit-Medium", size: size) != nil {
            return "NewSpirit-Medium"
        }
        if UIFont(name: "NatureSpiritRegular", size: size) != nil {
            return "NatureSpiritRegular"
        }
        return nil
    }
}

private struct PrototypeToolbarOverlay: View {
    let onBack: () -> Void

    private enum Layout {
        static let height: CGFloat = 99
        static let horizontalInset: CGFloat = 16
    }

    var body: some View {
        HStack {
            ToolbarGlassButton(icon: .back, accessibilityLabel: "Back", showsShadow: false, action: onBack)
            Spacer()
            ToolbarGlassPill(primaryAction: {}, secondaryAction: {}, showsShadow: false)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Layout.horizontalInset)
        .frame(height: Layout.height, alignment: .bottom)
    }
}
