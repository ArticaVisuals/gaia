import SwiftUI

struct ExploreScreen: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var contentStore: ContentStore
    @State private var sheetSnapshot = ExploreSheetSnapshot()
    @State private var searchQuery = ""
    @State private var recenterRequestID: UUID?
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        GeometryReader { proxy in
            let viewportWidth = min(proxy.size.width, UIScreen.main.bounds.width)
            let horizontalInset = GaiaSpacing.md
            let searchBarWidth = max(0, viewportWidth - (horizontalInset * 2))
            let searchBarTopInset = proxy.safeAreaInsets.top

            ExploreMapView(
                observations: contentStore.observations,
                recenterRequestID: recenterRequestID,
                onSelectObservation: { observation in
                    appState.openFindDetails(speciesID: observation.speciesID, tab: .learn)
                }
            )
            .ignoresSafeArea()
            .overlay(alignment: .bottom) {
                ExploreDraggableSheet(
                    species: contentStore.species,
                    projectCount: min(3, max(1, contentStore.observations.count)),
                    topInset: searchBarTopInset,
                    onSelectFind: { species in
                        appState.openFindDetails(speciesID: species.id, tab: .learn)
                    },
                    onProgressChange: { _ in },
                    onPositionChange: { snapshot in
                        sheetSnapshot = snapshot
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
            .overlay(alignment: .bottomLeading) {
                GlassCircleButton(size: 44, action: {
                    recenterRequestID = UUID()
                    isSearchFocused = false
                }) {
                    GaiaIcon(kind: .target, size: 24)
                }
                .padding(.leading, GaiaSpacing.md)
                .padding(.bottom, locateButtonBottomInset)
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
                    .padding(.top, searchBarTopInset + 8)
                    .frame(width: viewportWidth, alignment: .center)
            }
            .frame(width: viewportWidth, height: proxy.size.height)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var locateButtonBottomInset: CGFloat {
        guard sheetSnapshot.fullHeight > 0 else { return 226 }
        return max(120, (sheetSnapshot.fullHeight - sheetSnapshot.collapsedOffset) + 76)
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
        peekHeight = 150
        fullHeight = max(360, containerHeight - headerHeight)
        fullOffset = 16
        midOffset = max(fullOffset, round(fullHeight * 0.47))
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

    func fullExpansionProgress(for offset: CGFloat) -> CGFloat {
        let range = max(1, midOffset - fullOffset)
        return max(0, min(1, (midOffset - offset) / range))
    }

    func topPosition(for offset: CGFloat) -> CGFloat {
        headerHeight + offset
    }
}

private struct ExploreSheetSnapshot {
    var fullHeight: CGFloat = 0
    var liveOffset: CGFloat = 0
    var midOffset: CGFloat = 0
    var collapsedOffset: CGFloat = 0
}

private struct ExploreDraggableSheet: View {
    let species: [Species]
    let projectCount: Int
    let topInset: CGFloat
    let onSelectFind: (Species) -> Void
    let onProgressChange: (CGFloat) -> Void
    let onPositionChange: (ExploreSheetSnapshot) -> Void

    @State private var detent: ExploreSheetDetent = .collapsed
    @State private var dragTranslation: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            let metrics = ExploreSheetMetrics(containerHeight: proxy.size.height, topInset: topInset)
            let containerWidth = proxy.size.width
            let viewportWidth = min(containerWidth, UIScreen.main.bounds.width)
            let liveOffset = metrics.clampedOffset(metrics.offset(for: detent) + dragTranslation)
            let contentReveal = metrics.contentReveal(for: liveOffset)
            let fullExpansion = metrics.fullExpansionProgress(for: liveOffset)
            let contentOpacity = max(0, min(1, (contentReveal - 0.12) / 0.88))
            let peekOpacity = max(0, 1 - contentReveal * 1.35)
            let collapsedLift = (1 - contentReveal) * 14
            let peekInsets = EdgeInsets(
                top: (1 - contentReveal) * 4,
                leading: 0,
                bottom: (1 - contentReveal) * 12,
                trailing: 0
            )
            let shellHorizontalInset = (1 - contentReveal) * 12
            let shellWidth = max(0, viewportWidth - (shellHorizontalInset * 2))
            let topPosition = metrics.topPosition(for: liveOffset) - collapsedLift
            let visibleSheetHeight = max(metrics.peekHeight, metrics.fullHeight - liveOffset + collapsedLift)
            let activeDragHeight = detent == .full ? 112 : visibleSheetHeight

            ZStack(alignment: .top) {
                ExploreSheetSurface(contentReveal: contentReveal)
                    .padding(peekInsets)
                    .frame(width: shellWidth, height: visibleSheetHeight, alignment: .top)

                ExploreBottomSheet(
                    species: species,
                    onSelectFind: onSelectFind,
                    allowsScroll: detent == .full,
                    showsSurface: false
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
                    projectCount: projectCount,
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
            .onAppear {
                onProgressChange(fullExpansion)
                onPositionChange(
                    ExploreSheetSnapshot(
                        fullHeight: metrics.fullHeight,
                        liveOffset: liveOffset,
                        midOffset: metrics.midOffset,
                        collapsedOffset: metrics.collapsedOffset
                    )
                )
            }
            .onChange(of: liveOffset) { _, newValue in
                onProgressChange(fullExpansion)
                onPositionChange(
                    ExploreSheetSnapshot(
                        fullHeight: metrics.fullHeight,
                        liveOffset: newValue,
                        midOffset: metrics.midOffset
                    )
                )
            }
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

    private func dragSurface(height: CGFloat, metrics: ExploreSheetMetrics) -> some View {
        Rectangle()
            .fill(Color.black.opacity(0.001))
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .contentShape(Rectangle())
            .gesture(sheetInteractionGesture(metrics: metrics))
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
    let projectCount: Int
    let width: CGFloat

    var body: some View {
        ExploreSheetPeekCard(projectCount: projectCount, width: width)
            .padding(.top, 4)
            .padding(.bottom, 12)
            .frame(width: width, height: 150, alignment: .top)
    }
}

private struct ExploreSheetPeekCard: View {
    let projectCount: Int
    let width: CGFloat

    var body: some View {
        ZStack(alignment: .top) {
            Capsule()
                .fill(GaiaColor.greyMuted.opacity(0.25))
                .frame(width: 48, height: 4)
                .padding(.top, 9)

            Text("\(projectCount) nearby \(projectCount == 1 ? "project" : "projects")")
                .font(GaiaTypography.subheadSerif)
                .foregroundStyle(GaiaColor.olive)
                .lineLimit(1)
                .padding(.top, 28)
                .padding(.horizontal, 16)
                .frame(width: width, alignment: .center)
        }
        .frame(width: width, height: 134, alignment: .top)
    }
}

private struct ExploreSheetSurface: View {
    let contentReveal: CGFloat

    var body: some View {
        let topCorner = 35 + (GaiaRadius.sheet - 35) * contentReveal
        let bottomCorner = 35 * (1 - contentReveal)

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
            GaiaIcon(kind: .search, size: 32)
                .frame(width: 32, height: 32)

            TextField(
                "",
                text: $text,
                prompt: Text("Search finds")
                    .font(GaiaTypography.body)
                    .foregroundStyle(GaiaColor.blackishGrey500.opacity(0.5))
            )
            .font(GaiaTypography.body)
            .foregroundStyle(GaiaColor.textPrimary)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.search)
            .focused(isFocused)
            .frame(maxWidth: .infinity, alignment: .leading)

            GaiaIcon(kind: .microphone, size: 32, tint: GaiaColor.inkBlack900)
                .frame(width: 32, height: 32)
        }
        .padding(.leading, 11)
        .padding(.trailing, 10)
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .background(ExploreSearchBarBackground())
        .clipShape(Capsule())
        .contentShape(Capsule())
        .onTapGesture {
            isFocused.wrappedValue = true
        }
        .accessibilityLabel("Search finds")
    }
}

private struct ExploreSearchBarBackground: View {
    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 296, style: .continuous)
        let burnWhite = Color(red: 221 / 255, green: 221 / 255, blue: 221 / 255)
        let darkenWhite = Color(red: 247 / 255, green: 247 / 255, blue: 247 / 255)

        return ZStack {
            if #available(iOS 26.0, *) {
                Color.clear
                    .glassEffect(.regular, in: shape)
            } else {
                shape
                    .fill(.white.opacity(0.65))
                    .background(.ultraThinMaterial, in: shape)
            }

            shape
                .fill(.white)
                .blendMode(.multiply)

            shape
                .fill(burnWhite)
                .blendMode(.colorBurn)

            shape
                .fill(darkenWhite)
                .blendMode(.darken)
        }
        .compositingGroup()
        .shadow(color: GaiaColor.broccoliBrown500.opacity(0.24), radius: 40, x: 0, y: 8)
    }
}
