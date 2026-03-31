import SwiftUI

struct HeroCarousel: View {
    let imageNames: [String]
    let title: String
    let subtitle: String
    @State private var selection = 0

    var body: some View {
        VStack(spacing: GaiaSpacing.sm) {
            TabView(selection: $selection) {
                ForEach(Array(imageNames.enumerated()), id: \.offset) { index, imageName in
                    ProgressiveBlurImage(imageName: imageName)
                        .overlay(alignment: .bottomLeading) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(title)
                                    .font(GaiaTypography.displayMedium)
                                    .foregroundStyle(GaiaColor.paperStrong)
                                Text(subtitle.uppercased())
                                    .font(GaiaTypography.caption2)
                                    .foregroundStyle(GaiaColor.paperWhite100.opacity(0.92))
                            }
                            .padding(GaiaSpacing.md)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous))
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 286)

            HStack(spacing: 8) {
                ForEach(imageNames.indices, id: \.self) { index in
                    Capsule()
                        .fill(index == selection ? GaiaColor.olive : GaiaColor.border)
                        .frame(width: index == selection ? 20 : 8, height: 8)
                        .animation(GaiaMotion.quickEase, value: selection)
                }
            }
        }
    }
}
