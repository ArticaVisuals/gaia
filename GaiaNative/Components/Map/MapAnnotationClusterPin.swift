import SwiftUI

struct MapAnnotationClusterPin: View {
    let count: Int

    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [GaiaColor.grassGreen500, GaiaColor.olive],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 68, height: 68)
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.56), lineWidth: 1.5)
            )
            .overlay(
                Text("\(count)")
                    .font(GaiaTypography.display)
                    .foregroundStyle(Color(red: 224 / 255, green: 242 / 255, blue: 218 / 255))
            )
            .shadow(color: GaiaShadow.greenGlow, radius: 18, x: 0, y: 12)
    }
}
