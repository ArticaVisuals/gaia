import SwiftUI

struct GalleryRail: View {
    let imageNames: [String]

    private let itemWidths: [CGFloat] = [181, 112, 84, 181, 182]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(imageNames.enumerated()), id: \.offset) { index, imageName in
                    galleryImage(name: imageName, width: itemWidths[safe: index] ?? 112)
                }
            }
            .padding(.horizontal, GaiaSpacing.md)
        }
    }

    @ViewBuilder
    private func galleryImage(name: String, width: CGFloat) -> some View {
        let shape = RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)

        GaiaAssetImage(name: name)
            .aspectRatio(contentMode: .fill)
            .frame(width: width, height: 112)
            .clipShape(shape)
            .overlay(
                shape
                    .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
            )
            .shadow(color: GaiaShadow.smallColor, radius: GaiaShadow.smallRadius, x: 0, y: GaiaShadow.smallYOffset)
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
