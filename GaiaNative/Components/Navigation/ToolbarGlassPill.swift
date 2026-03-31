import SwiftUI

struct ToolbarGlassPill: View {
    let primaryAction: () -> Void
    let secondaryAction: () -> Void

    var body: some View {
        GlassPillButton {
            Button(action: primaryAction) {
                GaiaIcon(kind: .plus, size: 24)
                    .frame(width: 36, height: 36)
                    .fixedSize()
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Add")

            Button(action: secondaryAction) {
                GaiaIcon(kind: .share, size: 24)
                    .frame(width: 36, height: 36)
                    .fixedSize()
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Share")
        }
    }
}
