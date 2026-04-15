import SwiftUI

struct GaiaPressableCardStyle: ButtonStyle {
    var pressedScale: CGFloat = 0.97
    var pressedOpacity: Double = 0.96

    func makeBody(configuration: Configuration) -> some View {
        GaiaPressableCardStyleBody(
            configuration: configuration,
            pressedScale: pressedScale,
            pressedOpacity: pressedOpacity
        )
    }
}

private struct GaiaPressableCardStyleBody: View {
    let configuration: GaiaPressableCardStyle.Configuration
    let pressedScale: CGFloat
    let pressedOpacity: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1)
            .opacity(configuration.isPressed ? pressedOpacity : 1)
            .animation(pressAnimation, value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                guard isPressed else { return }
                HapticsService.selectionChanged()
            }
    }

    private var pressAnimation: Animation {
        if reduceMotion {
            return .easeOut(duration: 0.12)
        }

        return configuration.isPressed
            ? .smooth(duration: 0.18)
            : .bouncy(duration: 0.42, extraBounce: 0.18)
    }
}
