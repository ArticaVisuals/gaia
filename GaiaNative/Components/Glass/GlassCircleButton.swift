import SwiftUI

struct GlassReactiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.965 : 1)
            .animation(.interactiveSpring(response: 0.22, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

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
            ZStack {
                GaiaMaterialBackground(cornerRadius: size / 2, interactive: true)

                label()
                    .fixedSize()
                    .frame(width: size, height: size)
            }
            .frame(width: size, height: size)
            .contentShape(Circle())
            .clipShape(Circle())
        }
        .buttonStyle(GlassReactiveButtonStyle())
    }
}
