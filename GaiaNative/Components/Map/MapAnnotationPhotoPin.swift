import SwiftUI

struct MapAnnotationPhotoPin: View {
    var imageName: String?

    var body: some View {
        ZStack {
            Circle()
                .fill(GaiaColor.paperStrong)
                .frame(width: 58, height: 58)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.74), lineWidth: 2)
                )
                .shadow(color: GaiaShadow.greenGlow, radius: 18, x: 0, y: 10)

            if let imageName {
                GaiaAssetImage(name: imageName)
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [GaiaColor.grassGreen300, GaiaColor.olive],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 48, height: 48)
            }
        }
    }
}
