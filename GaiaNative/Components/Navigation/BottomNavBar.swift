// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=451-3759
import SwiftUI

struct BottomNavBar: View {
    @Binding var selection: AppSection

    @State private var previewSelection: AppSection?
    @State private var dragIndicatorX: CGFloat?
    @State private var isDragging = false

    private let pillWidth: CGFloat = 81
    private let pillHeight: CGFloat = 54
    private let barHeight: CGFloat = 64
    private let buttonHeight: CGFloat = 48
    private let leadingInset: CGFloat = 1
    private let trailingInset: CGFloat = 2
    private let verticalInset: CGFloat = 5

    var body: some View {
        GeometryReader { proxy in
            let sections = AppSection.allCases
            let layout = navLayout(for: proxy.size.width, count: sections.count)
            let visualSelection = previewSelection ?? selection
            let indicatorX = indicatorOffset(
                for: visualSelection,
                contentWidth: layout.contentWidth,
                slotWidth: layout.slotWidth
            )

            ZStack(alignment: .topLeading) {
                GaiaMaterialBackground(cornerRadius: 296)

                activePill
                    .frame(width: pillWidth, height: pillHeight)
                    .offset(
                        x: dragIndicatorX ?? indicatorX,
                        y: verticalInset
                    )
                    .animation(isDragging ? nil : .interpolatingSpring(duration: 0.35, bounce: 0.32), value: selection)
                    .animation(isDragging ? nil : .interpolatingSpring(duration: 0.35, bounce: 0.32), value: previewSelection)

                HStack(spacing: 0) {
                    ForEach(sections, id: \.id) { section in
                        VStack(spacing: 0) {
                            GaiaIcon(kind: iconKind(for: section, currentSelection: visualSelection), size: 32)

                            Text(section.title)
                                .font(GaiaTypography.nav)
                                .tracking(0.25)
                                .foregroundStyle(GaiaColor.olive)
                                .frame(width: 44)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding(.horizontal, 4)
                        .contentShape(Rectangle())
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(section.title)
                        .accessibilityAddTraits(.isButton)
                        .frame(width: layout.slotWidth, height: buttonHeight)
                    }
                }
                .padding(.leading, leadingInset)
                .padding(.trailing, trailingInset)
                .padding(.vertical, verticalInset)

                Rectangle()
                    .fill(Color.black.opacity(0.001))
                    .contentShape(Rectangle())
                    .gesture(interactionGesture(contentWidth: layout.contentWidth, slotWidth: layout.slotWidth))
            }
            .frame(height: barHeight)
            .contentShape(Rectangle())
        }
        .frame(height: barHeight)
    }

    private var activePill: some View {
        RoundedRectangle(cornerRadius: GaiaRadius.full, style: .continuous)
            .fill(GaiaColor.fillVibrantTertiary)
    }

    private func navLayout(for totalWidth: CGFloat, count: Int) -> (contentWidth: CGFloat, slotWidth: CGFloat) {
        let contentWidth = max(0, totalWidth - leadingInset - trailingInset)
        let slotWidth = contentWidth / CGFloat(max(1, count))
        return (contentWidth, slotWidth)
    }

    private func indicatorOffset(for section: AppSection, contentWidth: CGFloat, slotWidth: CGFloat) -> CGFloat {
        let index = CGFloat(AppSection.allCases.firstIndex(of: section) ?? 0)
        return leadingInset + (index * slotWidth) + ((slotWidth - pillWidth) / 2)
    }

    private func interactionGesture(contentWidth: CGFloat, slotWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let horizontalTravel = abs(value.translation.width)
                if !isDragging && horizontalTravel > 4 {
                    isDragging = true
                }

                guard isDragging else { return }

                let localX = value.location.x - leadingInset
                let minX = leadingInset
                let maxX = max(minX, leadingInset + contentWidth - pillWidth)
                let proposed = value.location.x - (pillWidth / 2)
                let clamped = min(max(proposed, minX), maxX)

                dragIndicatorX = clamped
                previewSelection = nearestSection(for: localX, slotWidth: slotWidth)
            }
            .onEnded { value in
                if !isDragging {
                    let tapTarget = nearestSection(for: value.location.x - leadingInset, slotWidth: slotWidth)
                    dragIndicatorX = nil
                    commit(tapTarget)
                    return
                }

                let localX = value.predictedEndLocation.x - leadingInset
                let target = nearestSection(for: localX, slotWidth: slotWidth)

                isDragging = false
                dragIndicatorX = nil
                commit(target, haptic: target != selection)
            }
    }

    private func nearestSection(for localX: CGFloat, slotWidth: CGFloat) -> AppSection {
        let rawIndex = Int((localX / max(slotWidth, 1)).rounded(.down))
        let clampedIndex = min(max(rawIndex, 0), AppSection.allCases.count - 1)
        return AppSection.allCases[clampedIndex]
    }

    private func iconKind(for section: AppSection, currentSelection: AppSection) -> GaiaIconKind {
        switch section {
        case .explore:
            return .explore(selected: true)
        case .log:
            return .log(selected: true)
        case .observe:
            return .observe(selected: true)
        case .activity:
            return .activity(selected: true)
        case .profile:
            return .profile(selected: true)
        }
    }

    private func commit(_ newValue: AppSection, haptic: Bool = true) {
        previewSelection = newValue
        if haptic {
            HapticsService.selectionChanged()
        }

        withAnimation(.interpolatingSpring(duration: 0.35, bounce: 0.32)) {
            selection = newValue
            previewSelection = nil
        }
    }
}
