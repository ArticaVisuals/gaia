import SwiftUI

struct GaiaMaterialBackground: View {
    var cornerRadius: CGFloat = GaiaRadius.full

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        ZStack {
            if #available(iOS 26.0, *) {
                Color.clear
                    .glassEffect(.regular, in: shape)
            } else {
                shape
                    .fill(.white.opacity(0.18))
                    .background(GaiaMaterial.toolbar, in: shape)
            }

            shape
                .fill(.white.opacity(0.09))

            LinearGradient(
                colors: [
                    .white.opacity(0.24),
                    .white.opacity(0.06),
                    .clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(shape)

            shape
                .stroke(.white.opacity(0.22), lineWidth: 0.5)
        }
        .compositingGroup()
        .shadow(color: GaiaShadow.navColor, radius: GaiaShadow.navRadius, x: 0, y: 8)
    }
}
