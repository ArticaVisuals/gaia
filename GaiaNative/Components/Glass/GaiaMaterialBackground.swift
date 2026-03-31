import SwiftUI

struct GaiaMaterialBackground: View {
    var cornerRadius: CGFloat = GaiaRadius.full

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        let burnWhite = Color(red: 221 / 255, green: 221 / 255, blue: 221 / 255)
        let darkenWhite = Color(red: 247 / 255, green: 247 / 255, blue: 247 / 255)

        Group {
            if #available(iOS 26.0, *) {
                Color.clear
                    .glassEffect(.regular, in: shape)
            } else {
                shape
                    .fill(.white.opacity(0.12))
                    .background(GaiaMaterial.toolbar, in: shape)
            }

            shape
                .fill(.white)
                .blendMode(.multiply)

            shape
                .fill(burnWhite)
                .blendMode(.colorBurn)

            shape
                .fill(darkenWhite)
                .blendMode(.darken)
        }
        .compositingGroup()
        .shadow(color: GaiaShadow.navColor, radius: GaiaShadow.navRadius, x: 0, y: 8)
    }
}
