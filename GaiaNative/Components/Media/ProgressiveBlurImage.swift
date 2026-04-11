import SwiftUI

struct ProgressiveBlurImage: View {
    let imageName: String
    var blurRadius: CGFloat = Layout.blurRadius
    var blurBleed: CGFloat = Layout.blurBleed
    var blurMaskStops: [Gradient.Stop] = Layout.blurMaskStops
    var readabilityStops: [Gradient.Stop] = Layout.readabilityStops
    var softnessRadius: CGFloat = 0
    var softnessOpacity: CGFloat = 0

    private enum Layout {
        static let blurRadius: CGFloat = 7.5
        static let blurBleed: CGFloat = 3
        static let blurMaskStops: [Gradient.Stop] = [
            .init(color: .clear, location: 0.4),
            .init(color: .black.opacity(0.2), location: 0.56),
            .init(color: .black.opacity(0.65), location: 0.78),
            .init(color: .black, location: 1)
        ]
        static let readabilityStops: [Gradient.Stop] = [
            .init(color: .clear, location: 0),
            .init(color: .clear, location: 0.41),
            .init(color: Color.black.opacity(0.5), location: 1)
        ]
    }

    var body: some View {
        baseImage
            .overlay {
                if softnessOpacity > 0, softnessRadius > 0 {
                    baseImage
                        .blur(radius: softnessRadius)
                        .opacity(softnessOpacity)
                        .allowsHitTesting(false)
                }
            }
            .overlay {
                blurredImageOverlay
            }
            .overlay {
                readabilityGradient
            }
            .clipped()
    }

    private var baseImage: some View {
        GaiaAssetImage(name: imageName)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var blurredImageOverlay: some View {
        baseImage
            .padding(-blurBleed)
            .blur(radius: blurRadius)
            .mask(blurMask)
            .allowsHitTesting(false)
    }

    private var blurMask: some View {
        LinearGradient(
            stops: blurMaskStops,
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var readabilityGradient: some View {
        LinearGradient(
            stops: readabilityStops,
            startPoint: .top,
            endPoint: .bottom
        )
        .allowsHitTesting(false)
    }
}
