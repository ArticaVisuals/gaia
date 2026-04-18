import SwiftUI

struct FindDetailsLearnFoundInMapArtwork: View {
    private enum Layout {
        static let imageName = "learn-map-profile-heatmap-figma"
        static let widthScale: CGFloat = 1.0348
        static let heightScale: CGFloat = 1.1963
    }

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            GaiaAssetImage(name: Layout.imageName, contentMode: .fill)
                .frame(
                    width: size.width * Layout.widthScale,
                    height: size.height * Layout.heightScale
                )
                .position(x: size.width / 2, y: size.height / 2)
                .clipped()
        }
        .allowsHitTesting(false)
    }
}
