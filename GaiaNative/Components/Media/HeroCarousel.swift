// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=665-4594
import SwiftUI

struct HeroCarousel: View {
    let imageNames: [String]
    let title: String
    let subtitle: String
    @State private var selection = 0
    private let heroShadow = Color(red: 115 / 255, green: 115 / 255, blue: 100 / 255, opacity: 0.42)

    private var carouselImages: [String] {
        let preferredImages = Array(imageNames.prefix(4))
        return preferredImages.isEmpty ? imageNames : preferredImages
    }

    var body: some View {
        VStack(spacing: 8) {
            TabView(selection: $selection) {
                ForEach(Array(carouselImages.enumerated()), id: \.offset) { index, imageName in
                    ProgressiveBlurImage(imageName: imageName)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 262)
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(GaiaTypography.displayMedium)
                        .foregroundStyle(GaiaColor.paperStrong)
                        .lineLimit(1)

                    Text(subtitle)
                        .font(.custom("Neue Haas Unica W1G", size: 11))
                        .foregroundStyle(GaiaColor.paperWhite50.opacity(0.95))
                        .tracking(0.25)
                        .textCase(.none)
                }
                .padding(.leading, 15)
                .padding(.bottom, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .allowsHitTesting(false)
            }
            .clipShape(
                UnevenRoundedRectangle(
                    cornerRadii: .init(
                        topLeading: 0,
                        bottomLeading: 8,
                        bottomTrailing: 8,
                        topTrailing: 0
                    ),
                    style: .continuous
                )
            )
            .shadow(
                color: heroShadow,
                radius: 20,
                x: 0,
                y: 6
            )

            HStack(spacing: 8) {
                ForEach(carouselImages.indices, id: \.self) { index in
                    Circle()
                        .fill(index == selection ? GaiaColor.olive : GaiaColor.oliveGreen200)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.horizontal, 24)
            .frame(height: 16)
        }
    }
}
