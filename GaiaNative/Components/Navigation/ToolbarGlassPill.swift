import SwiftUI

struct ToolbarGlassPillAction: Identifiable {
    let id = UUID()
    let icon: ToolbarGlassButtonIcon
    let accessibilityLabel: String
    let action: () -> Void
}

struct ToolbarGlassPill: View {
    let actions: [ToolbarGlassPillAction]
    var showsShadow: Bool = true

    init(
        primaryAction: @escaping () -> Void,
        secondaryAction: @escaping () -> Void,
        showsShadow: Bool = true
    ) {
        self.actions = [
            ToolbarGlassPillAction(icon: .plus, accessibilityLabel: "Add", action: primaryAction),
            ToolbarGlassPillAction(icon: .share, accessibilityLabel: "Share", action: secondaryAction)
        ]
        self.showsShadow = showsShadow
    }

    init(actions: [ToolbarGlassPillAction], showsShadow: Bool = true) {
        self.actions = actions
        self.showsShadow = showsShadow
    }

    var body: some View {
        GlassPillButton(showsShadow: showsShadow) {
            ForEach(Array(actions.enumerated()), id: \.element.id) { _, action in
                Button(action: action.action) {
                    ToolbarGlassPillIconArtwork(icon: action.icon)
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(GlassReactiveButtonStyle())
                .accessibilityLabel(action.accessibilityLabel)
            }
        }
    }
}

private struct ToolbarGlassPillIconArtwork: View {
    let icon: ToolbarGlassButtonIcon

    var body: some View {
        switch icon {
        case .plus:
            GaiaIcon(kind: .plus, size: 24)
        case .share:
            GaiaIcon(kind: .share, size: 24)
        case .gear:
            GaiaIcon(kind: .gear, size: 20)
        case .more:
            ToolbarGlassMoreGlyph()
                .frame(width: 16, height: 4)
        case .search:
            GaiaIcon(kind: .search, size: 20)
        case .back:
            GaiaIcon(kind: .back, size: 32)
        case .rightArrow:
            GaiaIcon(kind: .circleArrowRight, size: 16)
        case .close:
            GaiaIcon(kind: .close, size: 32)
        case .expand:
            GaiaIcon(kind: .expand, size: 24)
        case .filter:
            GaiaIcon(kind: .filter, size: 32)
        case .grid:
            GaiaIcon(kind: .grid, size: 32)
        case .list:
            GaiaIcon(kind: .list, size: 32)
        case .map:
            GaiaIcon(kind: .map, size: 32)
        case .binoculars:
            GaiaIcon(kind: .binoculars, size: 20)
        }
    }
}

private struct ToolbarGlassMoreGlyph: View {
    var body: some View {
        HStack(spacing: GaiaSpacing.xs) {
            Circle()
                .fill(GaiaColor.inkBlack900)
                .frame(width: 4, height: 4)
            Circle()
                .fill(GaiaColor.inkBlack900)
                .frame(width: 4, height: 4)
            Circle()
                .fill(GaiaColor.inkBlack900)
                .frame(width: 4, height: 4)
        }
        .accessibilityHidden(true)
    }
}
