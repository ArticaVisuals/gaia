// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=451-3049 (3-tab), 758-9254 (2-tab)
import SwiftUI

struct DraggableTabSwitch<T: Identifiable & Hashable>: View {
    let tabs: [T]
    @Binding var selection: T
    let tabWidth: CGFloat?
    let title: (T) -> String
    @State private var dragX: CGFloat?

    init(
        tabs: [T],
        selection: Binding<T>,
        tabWidth: CGFloat? = nil,
        title: @escaping (T) -> String
    ) {
        self.tabs = tabs
        self._selection = selection
        self.tabWidth = tabWidth
        self.title = title
    }

    var body: some View {
        GeometryReader { proxy in
            let tabCount = CGFloat(max(tabs.count, 1))
            let width = tabWidth ?? (proxy.size.width / tabCount)
            let trackWidth = width * tabCount
            let leadingInset = tabWidth == nil ? 0 : max((proxy.size.width - trackWidth) / 2, 0)
            ZStack(alignment: .bottomLeading) {
                Rectangle()
                    .fill(GaiaColor.blackishGrey200)
                    .frame(height: 1)
                    .frame(maxHeight: .infinity, alignment: .bottom)

                Rectangle()
                    .fill(GaiaColor.olive)
                    .frame(width: width, height: 3)
                    .offset(x: indicatorOffset(width: width, leadingInset: leadingInset, trackWidth: trackWidth), y: 0)
                    .animation(
                        GaiaMotion.spring,
                        value: indicatorOffset(width: width, leadingInset: leadingInset, trackWidth: trackWidth)
                    )

                HStack(spacing: 0) {
                    ForEach(tabs) { tab in
                        Button {
                            updateSelection(tab)
                        } label: {
                            Text(title(tab))
                                .gaiaFont(.body)
                                .foregroundStyle(selection == tab ? GaiaColor.olive : GaiaColor.blackishGrey200)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .frame(width: width)
                    }
                }
                .frame(width: trackWidth)
                .frame(maxWidth: .infinity, alignment: tabWidth == nil ? .leading : .center)
            }
            .contentShape(Rectangle())
            .highPriorityGesture(
                tabDragGesture(
                    width: width,
                    leadingInset: leadingInset,
                    trackWidth: trackWidth
                ),
                including: .gesture
            )
        }
        .frame(height: 52)
    }

    private var selectedIndex: Int {
        tabs.firstIndex(of: selection) ?? 0
    }

    private func indicatorOffset(width: CGFloat, leadingInset: CGFloat, trackWidth: CGFloat) -> CGFloat {
        let maxOffset = max(0, trackWidth - width)
        if let dragX {
            return leadingInset + max(0, min(dragX - (width / 2), maxOffset))
        }
        return leadingInset + (CGFloat(selectedIndex) * width)
    }

    private func tabDragGesture(width: CGFloat, leadingInset: CGFloat, trackWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 4, coordinateSpace: .local)
            .onChanged { value in
                let location = max(0, min(trackWidth - 1, value.location.x - leadingInset))
                dragX = location
                let index = Int(location / width)
                guard tabs.indices.contains(index) else { return }
                updateSelection(tabs[index], animated: false, triggersHaptics: false)
            }
            .onEnded { value in
                let location = max(0, min(trackWidth - 1, value.location.x - leadingInset))
                dragX = nil
                let index = Int(location / width)
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
