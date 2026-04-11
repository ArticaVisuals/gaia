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
    let action: () -> Void

    var body: some View {
        GlassCircleButton(action: action) {
            ToolbarGlassIconArtwork(icon: icon)
                .frame(width: icon.slotSize, height: icon.slotSize)
        }
        .accessibilityLabel(accessibilityLabel)
    }
}

struct ToolbarGlassLearnButton: View {
    let title: String
    let accessibilityLabel: String
    let action: () -> Void

    private enum Layout {
        static let width: CGFloat = 102
        static let height: CGFloat = 48
        static let horizontalPadding: CGFloat = 20
        static let contentSpacing: CGFloat = 8
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Layout.contentSpacing) {
                Text(title)
                    .gaiaFont(.bodyMedium)
                    .foregroundStyle(GaiaColor.paperWhite50)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .layoutPriority(1)

                GaiaIcon(kind: .back, size: 20, tint: GaiaColor.paperWhite50)
                    .rotationEffect(.degrees(180))
                    .frame(width: 20, height: 20)
            }
            .padding(.horizontal, Layout.horizontalPadding)
            .frame(width: Layout.width)
            .frame(height: Layout.height)
            .background(
                RoundedRectangle(cornerRadius: GaiaRadius.full, style: .continuous)
                    .fill(GaiaColor.broccoliBrown500)
                    .overlay(
                        RoundedRectangle(cornerRadius: GaiaRadius.full, style: .continuous)
                            .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
                    )
                    .shadow(
                        color: GaiaShadow.mdColor,
                        radius: GaiaShadow.mdRadius,
                        x: 0,
                        y: GaiaShadow.mdYOffset
                    )
            )
            .clipShape(Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
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
