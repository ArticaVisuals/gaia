import SwiftUI

struct GlassCardBackground: View {
    var cornerRadius: CGFloat = GaiaRadius.lg

    var body: some View {
        GaiaMaterialBackground(
            cornerRadius: cornerRadius,
            interactive: false,
            showsShadow: true
        )
    }
}
