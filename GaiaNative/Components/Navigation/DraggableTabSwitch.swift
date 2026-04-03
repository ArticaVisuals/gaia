// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=451-3049 (3-tab), 758-9254 (2-tab)
import SwiftUI

struct DraggableTabSwitch<T: Identifiable & Hashable>: View {
    let tabs: [T]
    @Binding var selection: T
    let title: (T) -> String
    @State private var dragX: CGFloat?

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width / CGFloat(max(tabs.count, 1))
            ZStack(alignment: .bottomLeading) {
                Rectangle()
                    .fill(GaiaColor.blackishGrey200)
                    .frame(height: 1)
                    .frame(maxHeight: .infinity, alignment: .bottom)

                Rectangle()
                    .fill(GaiaColor.olive)
                    .frame(width: width, height: 3)
                    .offset(x: indicatorOffset(width: width), y: 0)
                    .animation(GaiaMotion.spring, value: indicatorOffset(width: width))

                HStack(spacing: 0) {
                    ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                        Button {
                            updateSelection(tab)
                        } label: {
                            Text(title(tab))
                                .font(GaiaTypography.body)
                                .foregroundStyle(selection == tab ? GaiaColor.olive : GaiaColor.blackishGrey200)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .frame(width: width)
                    }
                }
            }
            .contentShape(Rectangle())
            .highPriorityGesture(tabDragGesture(proxy: proxy), including: .gesture)
        }
        .frame(height: 52)
    }

    private var selectedIndex: Int {
        tabs.firstIndex(of: selection) ?? 0
    }

    private func indicatorOffset(width: CGFloat) -> CGFloat {
        if let dragX {
            return max(0, min(dragX - (width / 2), width * CGFloat(max(tabs.count - 1, 0))))
        }
        return CGFloat(selectedIndex) * width
    }

    private func tabDragGesture(proxy: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 4, coordinateSpace: .local)
            .onChanged { value in
                let location = max(0, min(proxy.size.width - 1, value.location.x))
                dragX = location
                let index = Int((location / proxy.size.width) * CGFloat(tabs.count))
                guard tabs.indices.contains(index) else { return }
                updateSelection(tabs[index], animated: false, triggersHaptics: false)
            }
            .onEnded { value in
                let location = max(0, min(proxy.size.width - 1, value.location.x))
                dragX = nil
                let index = Int((location / proxy.size.width) * CGFloat(tabs.count))
                guard tabs.indices.contains(index) else { return }
                updateSelection(tabs[index], animated: true, triggersHaptics: false)
            }
    }

    private func updateSelection(_ tab: T, animated: Bool = true, triggersHaptics: Bool = true) {
        guard selection != tab else { return }
        if triggersHaptics {
            HapticsService.selectionChanged()
        }
        if animated {
            withAnimation(GaiaMotion.spring) {
                selection = tab
            }
        } else {
            selection = tab
        }
    }
}

struct HorizontalTabSwipeModifier<T: Hashable>: ViewModifier {
    let tabs: [T]
    @Binding var selection: T
    var onHorizontalDragStateChange: ((Bool) -> Void)? = nil

    @State private var dragOffset: CGFloat = 0
    @State private var axisLock: DragAxisLock = .undecided
    @State private var dragStartIndex: Int?
    @State private var isHorizontalDragActive = false

    private let gestureMinimumDistance: CGFloat = 10
    private let axisDecisionThreshold: CGFloat = 12
    private let minimumSwipeDistance: CGFloat = 46
    private let horizontalDominanceRatio: CGFloat = 1.25
    private let edgeResistanceFactor: CGFloat = 0.33
    private let velocitySwipeThreshold: CGFloat = 180

    private enum DragAxisLock {
        case undecided
        case horizontal
        case vertical
    }

    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .offset(x: dragOffset)
            .simultaneousGesture(
                DragGesture(minimumDistance: gestureMinimumDistance, coordinateSpace: .local)
                    .onChanged { value in
                        handleSwipeChanged(value)
                    }
                    .onEnded { value in
                        handleSwipeEnded(value)
                    },
                including: .gesture
            )
    }

    private func handleSwipeChanged(_ value: DragGesture.Value) {
        guard tabs.count > 1 else { return }

        if dragStartIndex == nil {
            dragStartIndex = tabs.firstIndex(of: selection) ?? 0
        }

        if axisLock == .undecided {
            let horizontalTravel = abs(value.translation.width)
            let verticalTravel = abs(value.translation.height)
            guard max(horizontalTravel, verticalTravel) >= axisDecisionThreshold else { return }

            if horizontalTravel > (verticalTravel * horizontalDominanceRatio) {
                axisLock = .horizontal
                setHorizontalDragActive(true)
            } else if verticalTravel > (horizontalTravel * horizontalDominanceRatio) {
                axisLock = .vertical
            } else {
                return
            }
        }

        guard axisLock == .horizontal else { return }

        let startIndex = dragStartIndex ?? (tabs.firstIndex(of: selection) ?? 0)
        let translationX = value.translation.width
        let isAtFirstTab = startIndex == 0 && translationX > 0
        let isAtLastTab = startIndex == tabs.count - 1 && translationX < 0
        let resistance = (isAtFirstTab || isAtLastTab) ? edgeResistanceFactor : 1

        dragOffset = translationX * resistance
    }

    private func handleSwipeEnded(_ value: DragGesture.Value) {
        defer {
            axisLock = .undecided
            dragStartIndex = nil
            setHorizontalDragActive(false)
        }

        guard tabs.count > 1 else {
            dragOffset = 0
            return
        }

        guard axisLock == .horizontal else {
            dragOffset = 0
            return
        }

        let startIndex = dragStartIndex ?? (tabs.firstIndex(of: selection) ?? 0)
        let projectedHorizontalTravel = abs(value.predictedEndTranslation.width) > abs(value.translation.width)
            ? value.predictedEndTranslation.width
            : value.translation.width
        let projectedVelocity = value.predictedEndTranslation.width - value.translation.width
        let isVelocitySwipe = abs(projectedVelocity) >= velocitySwipeThreshold

        var targetIndex = startIndex
        if abs(projectedHorizontalTravel) >= minimumSwipeDistance || isVelocitySwipe {
            targetIndex = projectedHorizontalTravel < 0 ? startIndex + 1 : startIndex - 1
        }
        targetIndex = min(max(targetIndex, 0), tabs.count - 1)

        let targetTab = tabs[targetIndex]
        let willChangeTab = targetTab != selection
        if willChangeTab {
            HapticsService.selectionChanged()
        }

        withAnimation(GaiaMotion.spring) {
            if willChangeTab {
                selection = targetTab
            }
            dragOffset = 0
        }
    }

    private func setHorizontalDragActive(_ isActive: Bool) {
        guard isHorizontalDragActive != isActive else { return }
        isHorizontalDragActive = isActive
        onHorizontalDragStateChange?(isActive)
    }
}

extension View {
    func horizontalTabSwipe<T: Hashable>(
        tabs: [T],
        selection: Binding<T>,
        onHorizontalDragStateChange: ((Bool) -> Void)? = nil
    ) -> some View {
        modifier(
            HorizontalTabSwipeModifier(
                tabs: tabs,
                selection: selection,
                onHorizontalDragStateChange: onHorizontalDragStateChange
            )
        )
    }
}
