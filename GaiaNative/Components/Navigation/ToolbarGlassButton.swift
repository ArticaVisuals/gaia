import SwiftUI

enum ToolbarGlassButtonIcon {
    case search
    case back
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

private struct ToolbarGlassIconArtwork: View {
    let icon: ToolbarGlassButtonIcon

    var body: some View {
        ZStack {
            switch icon {
            case .search:
                GaiaIcon(kind: .search, size: 20)
            case .back:
                GaiaAssetImage(name: "figma-left-arrow-tight", contentMode: .fit)
                    .frame(width: 15.6, height: 20.1)
                    .rotationEffect(.degrees(-90))
            case .close:
                GaiaIcon(kind: .close, size: 32)
            }
        }
        .frame(width: 32, height: 32)
    }
}
