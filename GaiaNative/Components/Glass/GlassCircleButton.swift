import SwiftUI

struct GlassCircleButton<Label: View>: View {
    let size: CGFloat
    let action: () -> Void
    @ViewBuilder let label: () -> Label

    init(size: CGFloat = 48, action: @escaping () -> Void, @ViewBuilder label: @escaping () -> Label) {
        self.size = size
        self.action = action
        self.label = label
    }

    var body: some View {
        Button(action: action) {
            label()
                .fixedSize()
                .frame(width: size, height: size)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .background(GaiaMaterialBackground(cornerRadius: size / 2))
        .clipShape(Circle())
    }
}
