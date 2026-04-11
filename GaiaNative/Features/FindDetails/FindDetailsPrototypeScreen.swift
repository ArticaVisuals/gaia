import SwiftUI
import UIKit

private enum FindDetailsPrototypeLayout {
    static let designWidth: CGFloat = 402
    static let expandedHeroHeight: CGFloat = 441
    static let collapsedHeroHeight: CGFloat = 228
    static let expandedImageHeight: CGFloat = 441
    static let collapsedImageHeight: CGFloat = 228
    static let expandedPanelTop: CGFloat = 428
    static let collapsedPanelTop: CGFloat = 205
    static let tabHeaderHeight: CGFloat = 60
    static let expandedContentOffset: CGFloat = 488
    static let collapsedContentOffset: CGFloat = 265
    static let contentTopPadding: CGFloat = 32
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
    @State private var scrollOriginY: CGFloat?
    @State private var scrollOffset: CGFloat = 0
    @State private var showsExpandedMap = false
    @State private var showsLearnScreen = false

    private let contentBottomInset = GaiaSpacing.xxxl + GaiaSpacing.xxl + GaiaSpacing.sm
    private let mapDataService = MapDataService()

    private enum FindMapReference {
        static let latitude = 35.1797
        static let longitude = -120.7361
    }

    private enum ScrollMarker: Hashable {
        case lockPoint
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
                                    geometry.frame(in: .global).minY
                                } action: { newValue in
                                    if let originY = scrollOriginY {
                                        scrollOffset = max(0, originY - newValue)
                                    } else {
                                        scrollOriginY = newValue
                                        scrollOffset = 0
                                    }
                                }

                            if isLockedScreenshotMode {
                                Color.clear
                                    .frame(height: metrics.collapsedContentOffset)
                            } else {
                                Color.clear
                                    .frame(height: metrics.collapseDistance)
                                    .id(ScrollMarker.lockPoint)

                                Color.clear
                                    .frame(height: metrics.collapsedContentOffset)
                            }

                            currentTabContent(
                                collapseProgress: collapseProgress,
                                usesCollapsedContentLayout: usesCollapsedContentLayout
                            )
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                                .padding(.top, metrics.contentTopPadding)
                                .offset(y: screenshotContentShift)

                            Color.clear
                                .frame(height: contentBottomInset)
                        }
                        .frame(width: contentWidth, alignment: .topLeading)
                    }
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

                    PrototypeToolbarOverlay(
                        onBack: { appState.closeFindDetailsPrototype() }
                    )
                    .frame(width: contentWidth, alignment: .top)
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            scrollOriginY = nil
            scrollOffset = 0
            selectedTab = prototypeSelection(for: appState.selectedFindTab)
            appState.selectedFindTab = selectedTab
            showsLearnScreen = launchArguments.contains("-gaiaFindDetailsPrototypeLearn")
        }
        .onChange(of: selectedTab) { _, newValue in
            if appState.selectedFindTab != newValue {
                appState.selectedFindTab = newValue
            }
        }
        .onChange(of: appState.selectedFindTab) { _, newValue in
            let normalizedSelection = prototypeSelection(for: newValue)
            if selectedTab != normalizedSelection {
                selectedTab = normalizedSelection
            }
        }
        .fullScreenCover(isPresented: $showsExpandedMap) {
            FindMapExpandedScreen(observation: findMapObservation(usesCollapsedContentLayout: false)) {
                showsExpandedMap = false
            }
        }
        .fullScreenCover(isPresented: $showsLearnScreen) {
            FindDetailsLearnScreen(
                species: species,
                observations: speciesObservations,
                stories: contentStore.stories,
                dismiss: { showsLearnScreen = false },
                onOpenStory: { story in
                    showsLearnScreen = false
                    appState.openStoryDeck(story.id)
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
            return -640
        }
        if launchArguments.contains("-gaiaFindDetailsPrototypeProjects") {
            return -540
        }
        return -360
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
        case .learn:
            EmptyView()
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
        Observation(
            id: "\(species.id)-prototype-find-preview",
            speciesID: species.id,
            latitude: FindMapReference.latitude,
            longitude: FindMapReference.longitude,
            thumbnailAssetName: (usesCollapsedContentLayout ? prototypePhotoAssetNames.first : prototypePhotoAssetNames.first)
                ?? contentStore.observations.first(where: { $0.speciesID == species.id })?.thumbnailAssetName
        )
    }

    private func prototypeSelection(for tab: FindDetailsTab) -> FindDetailsTab {
        switch tab {
        case .activity:
            return .activity
        case .find, .learn:
            return .find
        }
    }
}

private struct PrototypePanelSurface: View {
    private let topCornerRadius: CGFloat = 24

    var body: some View {
        UnevenRoundedRectangle(
            cornerRadii: .init(
                topLeading: topCornerRadius,
                bottomLeading: 0,
                bottomTrailing: 0,
                topTrailing: topCornerRadius
            ),
            style: .continuous
        )
        .fill(GaiaColor.paperWhite50)
        .shadow(color: GaiaShadow.cardColor, radius: GaiaShadow.cardRadius, x: 0, y: GaiaShadow.mdYOffset)
        .overlay {
            UnevenRoundedRectangle(
                cornerRadii: .init(
                    topLeading: topCornerRadius,
                    bottomLeading: 0,
                    bottomTrailing: 0,
                    topTrailing: topCornerRadius
                ),
                style: .continuous
            )
            .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
        }
        .allowsHitTesting(false)
    }
}

private struct PrototypeTabHeader: View {
    @Binding var selection: FindDetailsTab

    private let visibleTabs: [FindDetailsTab] = [.find, .activity]
    private let topCornerRadius: CGFloat = 24
    @State private var dragX: CGFloat?
    @State private var dragAxisLock: DragAxisLock = .undecided

    private let gestureMinimumDistance: CGFloat = 10
    private let axisDecisionThreshold: CGFloat = 12
    private let horizontalDominanceRatio: CGFloat = 1.25

    private enum DragAxisLock {
        case undecided
        case horizontal
        case vertical
    }

    var body: some View {
        GeometryReader { proxy in
            let topPadding = proxy.size.height * (16 / FindDetailsPrototypeLayout.tabHeaderHeight)
            let switchHeight = max(0, proxy.size.height - topPadding)
            let tabWidth = proxy.size.width / CGFloat(max(visibleTabs.count, 1))

            ZStack(alignment: .topLeading) {
                UnevenRoundedRectangle(
                    cornerRadii: .init(
                        topLeading: topCornerRadius,
                        bottomLeading: 0,
                        bottomTrailing: 0,
                        topTrailing: topCornerRadius
                    ),
                    style: .continuous
                )
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
                            .offset(x: indicatorOffset(tabWidth: tabWidth, totalWidth: proxy.size.width))
                            .animation(
                                dragX == nil ? GaiaMotion.spring : .interactiveSpring(response: 0.18, dampingFraction: 0.86),
                                value: indicatorOffset(tabWidth: tabWidth, totalWidth: proxy.size.width)
                            )
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
                    .contentShape(Rectangle())
                    .simultaneousGesture(selectionDragGesture(tabWidth: tabWidth, totalWidth: proxy.size.width))
                }
            }
            .clipShape(
                UnevenRoundedRectangle(
                    cornerRadii: .init(
                        topLeading: topCornerRadius,
                        bottomLeading: 0,
                        bottomTrailing: 0,
                        topTrailing: topCornerRadius
                    ),
                    style: .continuous
                )
            )
        }
    }

    private var selectedIndex: Int {
        visibleTabs.firstIndex(of: selection == .activity ? .activity : .find) ?? 0
    }

    private func indicatorOffset(tabWidth: CGFloat, totalWidth: CGFloat) -> CGFloat {
        let clampedDragX = min(max((dragX ?? (CGFloat(selectedIndex) * tabWidth + (tabWidth / 2))) - (tabWidth / 2), 0), totalWidth - tabWidth)
        return clampedDragX
    }

    private func selectionDragGesture(tabWidth: CGFloat, totalWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: gestureMinimumDistance, coordinateSpace: .local)
            .onChanged { value in
                if dragAxisLock == .undecided {
                    let horizontalTravel = abs(value.translation.width)
                    let verticalTravel = abs(value.translation.height)
                    guard max(horizontalTravel, verticalTravel) >= axisDecisionThreshold else { return }

                    if horizontalTravel > (verticalTravel * horizontalDominanceRatio) {
                        dragAxisLock = .horizontal
                    } else if verticalTravel > (horizontalTravel * horizontalDominanceRatio) {
                        dragAxisLock = .vertical
                    } else {
                        return
                    }
                }

                guard dragAxisLock == .horizontal else { return }
                dragX = max(0, min(totalWidth - 1, value.location.x))
            }
            .onEnded { value in
                defer {
                    dragAxisLock = .undecided
                }

                guard dragAxisLock == .horizontal else {
                    withAnimation(GaiaMotion.spring) {
                        dragX = nil
                    }
                    return
                }

                let projectedLocation = max(
                    0,
                    min(
                        totalWidth - 1,
                        abs(value.predictedEndTranslation.width) > abs(value.translation.width)
                            ? value.predictedEndLocation.x
                            : value.location.x
                    )
                )
                let index = min(max(Int(projectedLocation / tabWidth), 0), visibleTabs.count - 1)
                if visibleTabs.indices.contains(index) {
                    let target = visibleTabs[index]
                    if selection != target {
                        HapticsService.selectionChanged()
                        selection = target
                    }
                }

                withAnimation(GaiaMotion.spring) {
                    dragX = nil
                }
            }
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
        static let panelTopCornerRadius: CGFloat = 24
        static let expandedScientificTop: CGFloat = 289
        static let collapsedScientificTop: CGFloat = 57
        static let expandedTitleTop: CGFloat = 341
        static let collapsedTitleTop: CGFloat = 109
        static let expandedButtonTop: CGFloat = 361
        static let horizontalInset: CGFloat = 16
        static let learnButtonWidth: CGFloat = 117
        static let expandedTitleHeight: CGFloat = 68
        static let collapsedTitleHeight: CGFloat = 80
        static let scientificHeight: CGFloat = 32
        static let expandedBlurHeight: CGFloat = 441
        static let collapsedBlurHeight: CGFloat = 331
        static let collapsedBlurTop: CGFloat = 58.5
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
                proxy.size.height,
                max(0, visibleHeight + (Layout.panelTopCornerRadius * scale))
            )
            let blurStart = interpolate(
                from: 0.3322,
                to: Layout.collapsedBlurTop / FindDetailsPrototypeLayout.collapsedImageHeight
            )

            ZStack(alignment: .top) {
                if let imageName = species.galleryAssetNames.first {
                    ProgressiveBlurImage(
                        imageName: imageName,
                        blurRadius: 4.85 * scale,
                        blurBleed: 3 * scale,
                        blurMaskStops: heroBlurMaskStops(startLocation: blurStart),
                        readabilityStops: heroReadabilityStops
                    )
                        .frame(width: proxy.size.width, height: artworkHeight)
                        .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
                        .mask(alignment: .top) {
                            Rectangle()
                                .frame(maxWidth: .infinity)
                                .frame(height: artworkRevealHeight)
                        }
                } else {
                    GaiaColor.oliveGreen700
                }
            }
        }
    }

    private var heroCopy: some View {
        let scientificVisibility = max(0, 1 - min(clampedProgress * 1.55, 1))
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
                    .opacity(scientificVisibility)

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
            let topOffset = Layout.expandedButtonTop * scale

            ToolbarGlassLearnButton(title: "Learn", accessibilityLabel: "Learn", action: onLearnAction)
                .accessibilityHint("Opens the Learn details screen")
                .scaleEffect(scale, anchor: .topTrailing)
                .padding(.trailing, Layout.horizontalInset * scale)
                .offset(y: topOffset)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
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

    private func heroBlurMaskStops(startLocation: CGFloat) -> [Gradient.Stop] {
        [
            .init(color: .clear, location: 0),
            .init(color: .clear, location: startLocation),
            .init(color: .black, location: 1)
        ]
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
            ToolbarGlassButton(icon: .back, accessibilityLabel: "Back", action: onBack)
            Spacer()
            ToolbarGlassPill(primaryAction: {}, secondaryAction: {})
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Layout.horizontalInset)
        .frame(height: Layout.height, alignment: .bottom)
    }
}
