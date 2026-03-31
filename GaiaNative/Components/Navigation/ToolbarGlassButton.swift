import SwiftUI

enum ToolbarGlassButtonIcon {
    case search
    case back
    case close

    var gaiaIcon: GaiaIconKind {
        switch self {
        case .search:
            return .search
        case .back:
            return .back
        case .close:
            return .close
        }
    }

    var iconSize: CGFloat {
        switch self {
        case .search:
            return 20
        case .back, .close:
            return 32
        }
    }

    var slotSize: CGFloat {
        32
    }
}

struct ToolbarGlassButton: View {
    let icon: ToolbarGlassButtonIcon
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        GlassCircleButton(action: action) {
            GaiaIcon(kind: icon.gaiaIcon, size: icon.iconSize)
                .frame(width: icon.slotSize, height: icon.slotSize)
                .fixedSize()
        }
        .accessibilityLabel(accessibilityLabel)
    }
}
