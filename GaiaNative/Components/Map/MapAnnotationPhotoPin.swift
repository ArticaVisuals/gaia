// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=624-2133
import SwiftUI

struct MapAnnotationPhotoPin: View {
    var imageName: String?

    private let pinSize: CGFloat = 62
    private let imageSize: CGFloat = 52

    var body: some View {
        ZStack {
            pinGlassBorder

            if let imageName {
                GaiaAssetImage(name: imageName)
                    .frame(width: imageSize, height: imageSize)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(.black.opacity(0.08), lineWidth: 0.5)
                    )
            } else {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 123 / 255, green: 179 / 255, blue: 105 / 255),
                                Color(red: 110 / 255, green: 145 / 255, blue: 82 / 255)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: imageSize, height: imageSize)
            }
        }
        .frame(width: pinSize, height: pinSize)
        .shadow(color: GaiaShadow.greenGlow, radius: 18, x: 0, y: 10)
    }

    @ViewBuilder
    private var pinGlassBorder: some View {
        if #available(iOS 26.0, *) {
            Circle()
                .fill(.clear)
                .frame(width: pinSize, height: pinSize)
                .glassEffect(.regular, in: .circle)
        } else {
            Circle()
                .fill(.white.opacity(0.65))
                .frame(width: pinSize, height: pinSize)
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.74), lineWidth: 2)
                )
        }
    }
}

struct MapAnnotationBlankPin: View {
    private let pinSize: CGFloat = 62
    private let innerSize: CGFloat = 57

    var body: some View {
        ZStack {
            pinGlassBorder

            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 123 / 255, green: 179 / 255, blue: 105 / 255),
                            Color(red: 110 / 255, green: 145 / 255, blue: 82 / 255)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: innerSize, height: innerSize)
        }
        .frame(width: pinSize, height: pinSize)
        .shadow(color: GaiaShadow.greenGlow, radius: 18, x: 0, y: 12)
    }

    @ViewBuilder
    private var pinGlassBorder: some View {
        if #available(iOS 26.0, *) {
            Circle()
                .fill(.clear)
                .frame(width: pinSize, height: pinSize)
                .glassEffect(.regular, in: .circle)
        } else {
            Circle()
                .fill(.white.opacity(0.18))
                .frame(width: pinSize, height: pinSize)
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.56), lineWidth: 1.5)
                )
        }
    }
}
