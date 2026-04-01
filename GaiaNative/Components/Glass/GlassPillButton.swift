import SwiftUI

struct GlassPillButton<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack(spacing: 18) {
            content()
        }
        .padding(.horizontal, 10)
        .frame(height: 48)
        .background(GaiaMaterialBackground(cornerRadius: GaiaRadius.full, interactive: true))
        .clipShape(Capsule())
    }
}
