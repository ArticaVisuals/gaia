import SwiftUI

enum GaiaGlassProminence {
    case regular
    case prominent
}

enum GaiaGlassSurfaceStyle {
    case standard
    case toolbarButton
}

struct GaiaMaterialBackground: View {
    var cornerRadius: CGFloat = GaiaRadius.full
    var interactive: Bool = false
    var showsShadow: Bool = true
    var prominence: GaiaGlassProminence = .regular
    var surfaceStyle: GaiaGlassSurfaceStyle = .standard
    var tint: Color? = nil

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        shadowedSurface(surface(for: shape))
    }

    @available(iOS 26.0, *)
    private func liquidGlassLayer<S: Shape>(shape: S) -> some View {
        var glass = Glass.regular

        if let tint {
            let resolvedTint = prominence == .prominent ? tint.opacity(1) : tint
            glass = glass.tint(resolvedTint)
        }

        if interactive {
            glass = glass.interactive()
        }

        return Color.clear
            .glassEffect(glass, in: shape)
    }

    @ViewBuilder
    private func surface<S: Shape>(for shape: S) -> some View {
        switch surfaceStyle {
        case .standard:
            if #available(iOS 26.0, *) {
                liquidGlassLayer(shape: shape)
            } else {
                standardFallbackSurface(shape: shape)
            }
        case .toolbarButton:
            let fallbackSurface = toolbarButtonFallbackSurface(shape: shape)

            if #available(iOS 26.0, *) {
                ZStack {
                    fallbackSurface
                    liquidGlassLayer(shape: shape)
                }
            } else {
                fallbackSurface
            }
        }
    }

    private func standardFallbackSurface<S: Shape>(shape: S) -> some View {
        ZStack {
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
    }

    private func toolbarButtonFallbackSurface<S: Shape>(shape: S) -> some View {
        ZStack {
            shape
                .fill(.clear)
                .background(GaiaMaterial.toolbar, in: shape)

            shape
                .fill(.white.opacity(0.65))

            shape
                .fill(GaiaColor.toolbarGlassBurn)
                .blendMode(.colorBurn)

            shape
                .fill(GaiaColor.toolbarGlassDarken)
                .blendMode(.darken)

            if let tint {
                shape
                    .fill(tint.opacity(interactive ? 0.22 : 0.14))
            }
        }
        .compositingGroup()
    }

    @ViewBuilder
    private func shadowedSurface<Content: View>(_ content: Content) -> some View {
        if showsShadow {
            content.shadow(
                color: GaiaShadow.navColor,
                radius: GaiaShadow.navRadius,
                x: 0,
                y: GaiaShadow.navYOffset
            )
        } else {
            content
        }
    }
}
