// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=601-20725 (Bottom Button), 454-932 (Buttons)
import SwiftUI

struct GlassPillButton<Content: View>: View {
    var showsShadow: Bool = true
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack(spacing: 18) {
            content()
        }
        .padding(.horizontal, 10)
        .frame(height: 48)
        .background(
            GaiaMaterialBackground(
                cornerRadius: GaiaRadius.full,
                interactive: true,
                showsShadow: showsShadow
            )
        )
        .clipShape(Capsule())
    }
}
