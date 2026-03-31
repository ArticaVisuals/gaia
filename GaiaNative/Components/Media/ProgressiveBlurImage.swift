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
                .blur(radius: 16)
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0.0),
                            .init(color: .clear, location: 0.42),
                            .init(color: .black.opacity(0.58), location: 0.78),
                            .init(color: .black, location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .clipped()
    }
}
