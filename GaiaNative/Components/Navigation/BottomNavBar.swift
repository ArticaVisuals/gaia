import SwiftUI

struct BottomNavBar: View {
    @Binding var selection: AppSection

    @State private var previewSelection: AppSection?
    @State private var dragIndicatorX: CGFloat?
    @State private var isDragging = false

    private let pillWidth: CGFloat = 76
    private let barHeight: CGFloat = 56
    private let buttonHeight: CGFloat = 48
    private let leadingInset: CGFloat = 5
    private let trailingInset: CGFloat = 9
    private let verticalInset: CGFloat = 4

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
                navBackground

                activePill
                    .frame(width: pillWidth, height: buttonHeight)
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
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 2)
                        .padding(.horizontal, 4)
                        .padding(.bottom, 4)
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

    private var navBackground: some View {
        let shape = RoundedRectangle(cornerRadius: 296, style: .continuous)

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
                .fill(GaiaColor.paperStrong)
                .blendMode(.colorBurn)

            shape
                .fill(GaiaColor.paperStrong)
                .blendMode(.darken)
        }
        .compositingGroup()
        .shadow(color: GaiaShadow.navColor, radius: GaiaShadow.navRadius, x: 0, y: GaiaShadow.navYOffset)
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
        let centered = leadingInset + (index * slotWidth) + ((slotWidth - pillWidth) / 2)
        let minX = leadingInset
        let maxX = max(minX, leadingInset + contentWidth - pillWidth)
        return min(max(centered, minX), maxX)
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
        let isSelected = (currentSelection == section)
        switch section {
        case .explore:
            return .explore(selected: isSelected)
        case .log:
            return .log(selected: isSelected)
        case .observe:
            return .observe(selected: isSelected)
        case .activity:
            return .activity(selected: isSelected)
        case .profile:
            return .profile(selected: isSelected)
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
