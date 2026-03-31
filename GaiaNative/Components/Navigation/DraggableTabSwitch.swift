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
