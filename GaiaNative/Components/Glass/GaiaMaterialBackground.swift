import SwiftUI

enum GaiaGlassProminence {
    case regular
    case prominent
}

struct GaiaMaterialBackground: View {
    var cornerRadius: CGFloat = GaiaRadius.full
    var interactive: Bool = false
    var showsShadow: Bool = true
    var prominence: GaiaGlassProminence = .regular
    var tint: Color? = nil

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        let fallbackMaterial = ZStack {
            shape
                .fill(.white.opacity(0.18))
                .background(GaiaMaterial.toolbar, in: shape)

            shape
                .fill(.white.opacity(0.09))

            LinearGradient(
                colors: [
                    .white.opacity(0.24),
                    .white.opacity(0.06),
                    .clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(shape)

            if let tint {
                shape
                    .fill(tint.opacity(interactive ? 0.22 : 0.14))
            }

            shape
                .stroke(.white.opacity(0.22), lineWidth: 0.5)
        }
        .compositingGroup()

        Group {
            if #available(iOS 26.0, *) {
                liquidGlassLayer(shape: shape)
            } else {
                if showsShadow {
                    fallbackMaterial
                        .shadow(color: GaiaShadow.navColor, radius: GaiaShadow.navRadius, x: 0, y: 8)
                } else {
                    fallbackMaterial
                }
            }
        }
    }

    @available(iOS 26.0, *)
    private func liquidGlassLayer<S: Shape>(shape: S) -> some View {
        var glass = Glass.regular

        if let tint {
            glass = glass.tint(tint)
        }

        if interactive {
            glass = glass.interactive()
        }

        return Color.clear
            .glassEffect(glass, in: shape)
    }
}
