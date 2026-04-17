// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=582-15690
import SwiftUI

struct GlassReactiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1)
            .offset(y: configuration.isPressed ? 0.75 : 0)
            .brightness(configuration.isPressed ? -0.02 : 0)
            .saturation(configuration.isPressed ? 1.06 : 1)
            .animation(.interactiveSpring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct GlassCircleButton<Label: View>: View {
    let size: CGFloat
    let showsShadow: Bool
    let action: () -> Void
    @ViewBuilder let label: () -> Label

    init(
        size: CGFloat = 48,
        showsShadow: Bool = true,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.size = size
        self.showsShadow = showsShadow
        self.action = action
        self.label = label
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                GaiaMaterialBackground(
                    cornerRadius: size / 2,
                    interactive: true,
                    showsShadow: showsShadow
                )

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
