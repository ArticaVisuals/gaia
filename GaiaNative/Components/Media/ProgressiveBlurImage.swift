import SwiftUI

struct ProgressiveBlurImage: View {
    let imageName: String

    var body: some View {
        ZStack(alignment: .bottom) {
            GaiaAssetImage(name: imageName)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()

            GaiaAssetImage(name: imageName)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .blur(radius: 7.5)
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0.0),
                            .init(color: .clear, location: 0.22),
                            .init(color: .black.opacity(0.58), location: 0.72),
                            .init(color: .black, location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 146)

            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: Color.black.opacity(0.56), location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 146)
        }
        .clipped()
    }
}
