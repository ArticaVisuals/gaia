import SwiftUI

struct GalleryRail: View {
    let imageNames: [String]

    private let itemWidths: [CGFloat] = [181, 112, 84, 181, 182]
    private let itemHeight: CGFloat = 112

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: GaiaSpacing.sm) {
                ForEach(Array(imageNames.enumerated()), id: \.offset) { index, imageName in
                    galleryImage(name: imageName, index: index, width: itemWidths[safe: index] ?? 112)
                }
            }
            .padding(.horizontal, GaiaSpacing.md)
        }
    }

    @ViewBuilder
    private func galleryImage(name: String, index: Int, width: CGFloat) -> some View {
        let shape = RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)

        GeometryReader { proxy in
            galleryImageContent(name: name, index: index, size: proxy.size)
        }
            .frame(width: width, height: itemHeight)
            .clipShape(shape)
            .overlay(
                shape
                    .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
            )
            .shadow(color: GaiaShadow.smallColor, radius: GaiaShadow.smallRadius, x: 0, y: GaiaShadow.smallYOffset)
    }

    @ViewBuilder
    private func galleryImageContent(name: String, index: Int, size: CGSize) -> some View {
        switch index {
        case 0:
            GaiaAssetImage(name: name, contentMode: .fill)
                .frame(
                    width: size.width * 1.0221,
                    height: size.height * 1.2375
                )
                .offset(
                    x: -(size.width * 0.011),
                    y: -(size.height * 0.1187)
                )
        case 2:
            GaiaAssetImage(name: name, contentMode: .fill)
                .frame(width: size.width * 2.43, height: size.height)
                .offset(x: -(size.width * 0.86))
        default:
            GaiaAssetImage(name: name, contentMode: .fill)
                .frame(width: size.width, height: size.height)
        }
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
