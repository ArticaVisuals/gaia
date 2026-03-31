import SwiftUI

struct GaiaMaterialBackground: View {
    var cornerRadius: CGFloat = GaiaRadius.full

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        Group {
            if #available(iOS 26.0, *) {
                Color.clear
                    .glassEffect(.regular, in: shape)
            } else {
                shape
                    .fill(.white.opacity(0.12))
                    .background(GaiaMaterial.toolbar, in: shape)
                    .overlay(
                        shape
                            .stroke(.white.opacity(0.18), lineWidth: 0.5)
                    )
            }
        }
        .shadow(color: GaiaShadow.navColor, radius: GaiaShadow.navRadius, x: 0, y: 8)
    }
}
