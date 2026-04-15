// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=289-2158
import SwiftUI

struct ExploreScreen: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var contentStore: ContentStore
    @State private var searchQuery = ""
    @State private var recenterRequestID: UUID?
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        GeometryReader { proxy in
            let viewportWidth = min(proxy.size.width, UIScreen.main.bounds.width)
            let viewportHeight = max(proxy.size.height, UIScreen.main.bounds.height)
            let horizontalInset: CGFloat = 16
            let searchBarWidth = max(0, viewportWidth - (horizontalInset * 2))
            let searchBarTopInset = proxy.safeAreaInsets.top

            ExploreMapView(
                observations: contentStore.observations,
                recenterRequestID: recenterRequestID,
                onSelectObservation: { observation in
                    appState.openFindDetails(speciesID: observation.speciesID, tab: .learn)
                },
                prefersInitialUserLocation: true
            )
            .ignoresSafeArea()
            .overlay(alignment: .bottom) {
                ExploreDraggableSheet(
                    species: contentStore.species,
                    nearbyFindCount: max(12, contentStore.observations.count),
                    topInset: searchBarTopInset,
                    onSelectFind: { species in
                        appState.openFindDetails(speciesID: species.id, tab: .learn)
                    },
                    onSelectProject: { project in
                        appState.openProjectDetail(project)
                    },
                    onLocate: {
                        recenterRequestID = UUID()
                        isSearchFocused = false
                    }
                )
                .frame(width: viewportWidth, height: viewportHeight, alignment: .bottom)
                .ignoresSafeArea(edges: .bottom)
            }
            .overlay {
                if isSearchFocused {
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isSearchFocused = false
                        }
                }
            }
            .overlay(alignment: .top) {
                ExploreSearchBar(text: $searchQuery, isFocused: $isSearchFocused)
                    .frame(width: searchBarWidth)
                    .padding(.top, searchBarTopInset)
                    .frame(width: viewportWidth, alignment: .center)
            }
            .frame(width: viewportWidth, height: viewportHeight)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(edges: .bottom)
        }
    }

}

private enum ExploreSheetDetent: CaseIterable {
    case collapsed
    case mid
    case full
}

private struct ExploreSheetMetrics {
    let headerHeight: CGFloat
    let peekHeight: CGFloat
    let fullHeight: CGFloat
    let fullOffset: CGFloat
    let collapsedOffset: CGFloat
    let midOffset: CGFloat

    init(containerHeight: CGFloat, topInset: CGFloat) {
        headerHeight = topInset + 48
        fullHeight = max(360, containerHeight - headerHeight)
        fullOffset = 12
        // Figma ratios — sheet top at ~50% for mid, ~73% for collapsed
        peekHeight = round(containerHeight * 0.243)
        midOffset = max(fullOffset, round(fullHeight * 0.43))
        collapsedOffset = max(midOffset, fullHeight - peekHeight)
    }

    func offset(for detent: ExploreSheetDetent) -> CGFloat {
        switch detent {
        case .collapsed:
            return collapsedOffset
        case .mid:
            return midOffset
        case .full:
            return fullOffset
        }
    }

    func clampedOffset(_ value: CGFloat) -> CGFloat {
        min(max(value, fullOffset - 20), collapsedOffset + 20)
    }

    func nearestDetent(for projectedOffset: CGFloat) -> ExploreSheetDetent {
        let candidates: [(ExploreSheetDetent, CGFloat)] = [
            (.full, fullOffset),
            (.mid, midOffset),
            (.collapsed, collapsedOffset)
        ]

        return candidates.min { lhs, rhs in
            abs(lhs.1 - projectedOffset) < abs(rhs.1 - projectedOffset)
        }?.0 ?? .mid
    }

    func contentReveal(for offset: CGFloat) -> CGFloat {
        let range = max(1, collapsedOffset - midOffset)
        return max(0, min(1, (collapsedOffset - offset) / range))
    }

    func topPosition(for offset: CGFloat) -> CGFloat {
        headerHeight + offset
    }
}

private struct ExploreDraggableSheet: View {
    let species: [Species]
    let nearbyFindCount: Int
    let topInset: CGFloat
    let onSelectFind: (Species) -> Void
    let onSelectProject: (ProjectSelection) -> Void
    let onLocate: () -> Void

    @State private var detent: ExploreSheetDetent
    @State private var dragTranslation: CGFloat = 0

    init(
        species: [Species],
        nearbyFindCount: Int,
        topInset: CGFloat,
        onSelectFind: @escaping (Species) -> Void,
        onSelectProject: @escaping (ProjectSelection) -> Void,
        onLocate: @escaping () -> Void
    ) {
        self.species = species
        self.nearbyFindCount = nearbyFindCount
        self.topInset = topInset
        self.onSelectFind = onSelectFind
        self.onSelectProject = onSelectProject
        self.onLocate = onLocate
        _detent = State(initialValue: Self.launchDetent)
    }

    var body: some View {
        GeometryReader { proxy in
            let metrics = ExploreSheetMetrics(containerHeight: proxy.size.height, topInset: topInset)
            let containerWidth = proxy.size.width
            let viewportWidth = min(containerWidth, UIScreen.main.bounds.width)
            let liveOffset = metrics.clampedOffset(metrics.offset(for: detent) + dragTranslation)
            let contentReveal = metrics.contentReveal(for: liveOffset)
            let contentOpacity = max(0, min(1, (contentReveal - 0.12) / 0.88))
            let peekOpacity = max(0, 1 - contentReveal * 1.35)
            let collapsedLift = (1 - contentReveal) * 14
            let shellHorizontalInset = (1 - contentReveal) * 12
            let shellBottomInset = shellHorizontalInset
            let collapsedBottomLift = (1 - contentReveal) * 14
            let peekInsets = EdgeInsets(
                top: (1 - contentReveal) * 4,
                leading: 0,
                bottom: shellBottomInset,
                trailing: 0
            )
            let shellWidth = max(0, viewportWidth - (shellHorizontalInset * 2))
            let topPosition = metrics.topPosition(for: liveOffset) - collapsedLift - shellBottomInset - collapsedBottomLift
            // In collapsed state, the sheet is a floating 190pt card (166pt Figma card + top/bottom padding).
            // In mid/full, it extends to the container bottom.
            let expandedSheetHeight = metrics.fullHeight - liveOffset + collapsedLift
            let collapsedCardHeight: CGFloat = 190
            let visibleSheetHeight = collapsedCardHeight + (expandedSheetHeight - collapsedCardHeight) * contentReveal
            let activeDragHeight = detent == .full ? 112 : visibleSheetHeight

            locateButton(topPosition: topPosition, metrics: metrics)
                .position(
                    x: GaiaSpacing.md + 24,
                    y: topPosition - 42
                )
                .animation(GaiaMotion.softSpring, value: detent)
                .animation(.interactiveSpring(response: 0.28, dampingFraction: 0.88), value: dragTranslation)

            ZStack(alignment: .top) {
                ExploreSheetSurface(contentReveal: contentReveal)
                    .padding(peekInsets)
                    .frame(width: shellWidth, height: visibleSheetHeight, alignment: .top)

                ExploreBottomSheet(
                    species: species,
                    onSelectFind: onSelectFind,
                    onSelectProject: onSelectProject,
                    allowsScroll: detent == .full,
                    showsSurface: false,
                    onPullDownCollapse: {
                        requestContentCollapse()
                    }
                )
                .frame(width: shellWidth, alignment: .top)
                .frame(height: visibleSheetHeight, alignment: .top)
                .opacity(contentOpacity)
                .allowsHitTesting(contentOpacity > 0.55)
                .overlay(alignment: .top) {
                    if detent == .full {
                        dragSurface(height: activeDragHeight, metrics: metrics)
                    } else {
                        dragSurface(height: visibleSheetHeight, metrics: metrics)
                    }
                }

                ExploreCollapsedPanel(
                    nearbyFindCount: nearbyFindCount,
                    width: shellWidth
                )
                .opacity(peekOpacity)
                .allowsHitTesting(detent == .collapsed && peekOpacity > 0.25)
                .overlay {
                        if detent == .collapsed {
                            dragSurface(height: 150, metrics: metrics)
                    }
                }
            }
            .frame(width: shellWidth, height: visibleSheetHeight, alignment: .top)
            .position(
                x: containerWidth / 2,
                y: topPosition + (visibleSheetHeight / 2)
            )
            .overlay(alignment: .topTrailing) {
                Color.clear
                    .frame(width: 1, height: 1)
                    .accessibilityLabel("Explore sheet \(accessibilityLabel(for: liveOffset, metrics: metrics))")
                    .opacity(0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea(edges: .bottom)
            .animation(GaiaMotion.softSpring, value: detent)
            .animation(.interactiveSpring(response: 0.28, dampingFraction: 0.88), value: dragTranslation)
        }
    }

    private static var launchDetent: ExploreSheetDetent {
        let arguments = ProcessInfo.processInfo.arguments

        guard let flagIndex = arguments.firstIndex(of: "-gaiaExploreSheet"),
              arguments.indices.contains(flagIndex + 1) else {
            return .collapsed
        }

        switch arguments[flagIndex + 1].lowercased() {
        case "full":
            return .full
        case "mid", "half":
            return .mid
        default:
            return .collapsed
        }
    }

    private func sheetInteractionGesture(metrics: ExploreSheetMetrics) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard abs(value.translation.height) > 3 else { return }
                dragTranslation = value.translation.height
            }
            .onEnded { value in
                let delta = value.translation.height
                guard abs(delta) > 6 else {
                    dragTranslation = 0
                    if detent == .collapsed {
                        withAnimation(GaiaMotion.softSpring) {
                            detent = .mid
                        }
                    }
                    return
                }

                let predictedOffset = metrics.clampedOffset(
                    metrics.offset(for: detent) + value.predictedEndTranslation.height
                )
                let resolvedDetent: ExploreSheetDetent

                dragTranslation = 0

                switch detent {
                case .collapsed:
                    if predictedOffset <= metrics.midOffset || delta < -36 {
                        resolvedDetent = .mid
                    } else {
                        resolvedDetent = .collapsed
                    }
                case .mid:
                    if predictedOffset <= metrics.fullOffset + 80 || delta < -56 {
                        resolvedDetent = .full
                    } else if predictedOffset >= metrics.collapsedOffset - 56 || delta > 56 {
                        resolvedDetent = .collapsed
                    } else {
                        resolvedDetent = .mid
                    }
                case .full:
                    if predictedOffset >= metrics.midOffset || delta > 36 {
                        resolvedDetent = .mid
                    } else {
                        resolvedDetent = .full
                    }
                }

                withAnimation(GaiaMotion.softSpring) {
                    detent = resolvedDetent
                }
            }
    }

    private func locateButton(topPosition: CGFloat, metrics: ExploreSheetMetrics) -> some View {
        let fullRange = max(1, metrics.midOffset - 12)
        let liveOffset = metrics.clampedOffset(metrics.offset(for: detent) + dragTranslation)
        let progress = max(0, min(1, (metrics.midOffset - liveOffset) / fullRange))
        let opacity = 1 - progress

        return GlassCircleButton(size: 48, action: onLocate) {
            ExploreTargetIcon()
                .frame(width: 26, height: 26)
        }
        .opacity(opacity)
        .scaleEffect(0.96 + (opacity * 0.04))
        .allowsHitTesting(opacity > 0.08)
    }

    private func dragSurface(height: CGFloat, metrics: ExploreSheetMetrics) -> some View {
        Rectangle()
            .fill(Color.black.opacity(0.001))
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .contentShape(Rectangle())
            .gesture(sheetInteractionGesture(metrics: metrics))
    }

    private func requestContentCollapse() {
        let nextDetent: ExploreSheetDetent

        switch detent {
        case .full:
            nextDetent = .mid
        case .mid:
            nextDetent = .collapsed
        case .collapsed:
            return
        }

        dragTranslation = 0
        withAnimation(GaiaMotion.softSpring) {
            detent = nextDetent
        }
    }

    private func accessibilityLabel(for offset: CGFloat, metrics: ExploreSheetMetrics) -> String {
        let resolvedDetent = metrics.nearestDetent(for: offset)
        switch resolvedDetent {
        case .collapsed:
            return "collapsed"
        case .mid:
            return "half expanded"
        case .full:
            return "fully expanded"
        }
    }
}

private struct ExploreCollapsedPanel: View {
    let nearbyFindCount: Int
    let width: CGFloat

    var body: some View {
        ExploreSheetPeekCard(nearbyFindCount: nearbyFindCount, width: width)
            .padding(.top, 4)
            .padding(.bottom, 4)
            .frame(width: width, height: 166, alignment: .top)
    }
}

private struct ExploreSheetPeekCard: View {
    let nearbyFindCount: Int
    let width: CGFloat

    var body: some View {
        ZStack(alignment: .top) {
            Capsule()
                .fill(GaiaColor.greyMuted.opacity(0.25))
                .frame(width: 48, height: 4)
                .padding(.top, 9)

            Text("\(nearbyFindCount) nearby \(nearbyFindCount == 1 ? "find" : "finds")")
                .gaiaFont(.subheadSerif)
                .foregroundStyle(GaiaColor.olive)
                .lineLimit(1)
                .padding(.top, 22)
                .padding(.horizontal, 16)
                .frame(width: width, alignment: .center)
        }
        .frame(width: width, height: 166, alignment: .top)
    }
}

private struct ExploreSheetSurface: View {
    let contentReveal: CGFloat

    var body: some View {
        // Collapsed (contentReveal=0): floating card → 50px all corners
        // Mid/Full (contentReveal=1): extends to bottom → 48px top, 0 bottom
        let topCorner = 50 + (48 - 50) * contentReveal
        let bottomCorner = 50 * (1 - contentReveal)

        UnevenRoundedRectangle(
            cornerRadii: .init(
                topLeading: topCorner,
                bottomLeading: bottomCorner,
                bottomTrailing: bottomCorner,
                topTrailing: topCorner
            ),
            style: .continuous
        )
        .fill(GaiaColor.surfaceSheet)
        .overlay(
            UnevenRoundedRectangle(
                cornerRadii: .init(
                    topLeading: topCorner,
                    bottomLeading: bottomCorner,
                    bottomTrailing: bottomCorner,
                    topTrailing: topCorner
                ),
                style: .continuous
            )
            .stroke(GaiaColor.borderStrong, lineWidth: 0.5)
        )
        .shadow(color: GaiaShadow.mediumColor, radius: 24, x: 0, y: -4)
    }
}

private struct ExploreSearchBar: View {
    @Binding var text: String
    let isFocused: FocusState<Bool>.Binding

    var body: some View {
        HStack(spacing: 4) {
            ExploreSearchIcon()
                .frame(width: 32, height: 32)

            TextField(
                "",
                text: $text,
                prompt: Text("Search finds")
                    .font(GaiaTypography.body)
                    .foregroundStyle(GaiaColor.blackishGrey500.opacity(0.5))
            )
            .gaiaFont(.body)
            .foregroundStyle(GaiaColor.textPrimary)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.search)
            .focused(isFocused)
            .frame(maxWidth: .infinity, alignment: .leading)

            GaiaIcon(kind: .microphone, size: 32, tint: GaiaColor.olive)
                .frame(width: 32, height: 32)
        }
        .padding(.leading, 11)
        .padding(.trailing, 10)
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .background(GaiaMaterialBackground(cornerRadius: 296, interactive: true))
        .clipShape(Capsule())
        .contentShape(Capsule())
        .onTapGesture {
            isFocused.wrappedValue = true
        }
        .accessibilityLabel("Search finds")
    }
}

private struct ExploreSearchIcon: View {
    var body: some View {
        Group {
            if let uiImage = AssetCatalog.uiImage(named: "Icons/System/search-20.png") {
                Image(uiImage: uiImage)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(GaiaColor.olive)
            }
        }
        .frame(width: 20, height: 20)
    }
}

private struct ExploreTargetIcon: View {
    var body: some View {
        ZStack {
            if let ring = AssetCatalog.uiImage(named: "Icons/System/target-24-ring.png") {
                Image(uiImage: ring)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(GaiaColor.olive)
            }

            if let dot = AssetCatalog.uiImage(named: "Icons/System/target-24-dot.png") {
                Image(uiImage: dot)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(GaiaColor.olive)
                    .padding(8)
            }
        }
    }
}
