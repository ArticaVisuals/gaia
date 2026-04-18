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
        GlassPillButton(showsShadow: showsShadow, spacing: 18) {
            ForEach(Array(actions.enumerated()), id: \.element.id) { _, action in
                Button(action: action.action) {
                    ToolbarGlassIconArtwork(icon: action.icon)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(GlassReactiveButtonStyle())
                .accessibilityLabel(action.accessibilityLabel)
            }
        }
    }
}
