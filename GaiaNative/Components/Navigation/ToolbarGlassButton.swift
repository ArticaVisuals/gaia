// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=451-702
import SwiftUI

enum ToolbarGlassButtonIcon {
    case search
    case back
    case rightArrow
    case close

    var slotSize: CGFloat { 32 }
}

struct ToolbarGlassButton: View {
    let icon: ToolbarGlassButtonIcon
    let accessibilityLabel: String
    var showsShadow: Bool = true
    let action: () -> Void

    var body: some View {
        GlassCircleButton(showsShadow: showsShadow, action: action) {
            ToolbarGlassIconArtwork(icon: icon)
                .frame(width: icon.slotSize, height: icon.slotSize)
        }
        .accessibilityLabel(accessibilityLabel)
    }
}

struct ToolbarGlassLearnButton: View {
    let title: String
    let accessibilityLabel: String
    var showsShadow: Bool = true
    let action: () -> Void

    @State private var shimmerPhase: CGFloat = 0

    private enum Layout {
        static let horizontalPadding: CGFloat = 20
        static let verticalPadding: CGFloat = 14
        static let contentSpacing: CGFloat = 8
        static let borderWidth: CGFloat = 1.0
        static let arrowAssetWidth: CGFloat = 15.59
        static let arrowAssetHeight: CGFloat = 20.103
        static let arrowWidth: CGFloat = 20.103
        static let arrowHeight: CGFloat = 15.59
        static let shadowColor = GaiaColor.broccoliBrown500

        // Figma stroke gradient stops
        static let strokeHighlight = Color(red: 0.847, green: 0.788, blue: 0.722) // #D8C9B8
        static let strokeShadow = Color(red: 0.447, green: 0.416, blue: 0.381) // #726A61
    }

    /// Stroke gradient that matches Figma: bright → dark → bright, rotated by shimmerPhase
    private var strokeGradient: AngularGradient {
        AngularGradient(
            stops: [
                .init(color: Layout.strokeHighlight, location: 0.0),
                .init(color: Layout.strokeShadow, location: 0.275),
                .init(color: Layout.strokeHighlight, location: 0.5),
                .init(color: Layout.strokeShadow, location: 0.775),
                .init(color: Layout.strokeHighlight, location: 1.0),
            ],
            center: .center,
            angle: .degrees(shimmerPhase)
        )
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Layout.contentSpacing) {
                Text(title)
                    .font(GaiaTypography.bodyMedium)
                    .tracking(0)
                    .foregroundStyle(GaiaColor.paperWhite50)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: true)
                    .layoutPriority(1)

                rightArrowArtwork
                    .frame(width: Layout.arrowAssetWidth, height: Layout.arrowAssetHeight)
                    .rotationEffect(.degrees(90))
                    .frame(width: Layout.arrowWidth, height: Layout.arrowHeight)
            }
            .padding(.horizontal, Layout.horizontalPadding)
            .padding(.vertical, Layout.verticalPadding)
            .background {
                let shape = Capsule(style: .continuous)

                shape
                    .fill(GaiaColor.broccoliBrown500)
                    .overlay(
                        shape
                            .stroke(strokeGradient, lineWidth: Layout.borderWidth)
                    )
                    .shadow(
                        color: showsShadow ? Layout.shadowColor : .clear,
                        radius: GaiaShadow.mdRadius,
                        x: 0,
                        y: GaiaShadow.mdYOffset
                    )
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .onAppear {
            withAnimation(
                .linear(duration: 6)
                .repeatForever(autoreverses: false)
            ) {
                shimmerPhase = 360
            }
        }
    }

    @ViewBuilder
    private var rightArrowArtwork: some View {
        if let image = AssetCatalog.image(named: "gaia-icon-back-32") {
            image
                .resizable()
                .renderingMode(.template)
                .interpolation(.high)
                .antialiased(true)
                .scaledToFit()
                .foregroundStyle(GaiaColor.paperWhite50)
        }
    }
}

private struct ToolbarGlassIconArtwork: View {
    let icon: ToolbarGlassButtonIcon

    var body: some View {
        ZStack {
            switch icon {
            case .search:
                GaiaIcon(kind: .search, size: 20)
            case .back:
                GaiaAssetImage(name: "gaia-icon-back-32", contentMode: .fit)
                    .frame(width: 15.6, height: 20.1)
                    .rotationEffect(.degrees(-90))
            case .rightArrow:
                GaiaAssetImage(name: "gaia-icon-back-32", contentMode: .fit)
                    .frame(width: 15.6, height: 20.1)
                    .rotationEffect(.degrees(90))
            case .close:
                GaiaIcon(kind: .close, size: 32)
            }
        }
        .frame(width: 32, height: 32)
    }
}
