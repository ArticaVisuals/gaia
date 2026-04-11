import SwiftUI

private enum GalleryRailLayout {
    static let height: CGFloat = 112
    static let itemSpacing: CGFloat = GaiaSpacing.sm
    static let horizontalInset: CGFloat = GaiaSpacing.md
    static let defaultItemWidth: CGFloat = 112
}

struct GalleryRail: View {
    let imageNames: [String]

    private let itemWidths: [CGFloat] = [181, 112, 84, 181, 182]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: GalleryRailLayout.itemSpacing) {
                ForEach(Array(imageNames.enumerated()), id: \.offset) { index, imageName in
                    galleryImage(
                        name: imageName,
                        width: itemWidths[safe: index] ?? GalleryRailLayout.defaultItemWidth
                    )
                }
            }
            .scrollTargetLayout()
        }
        .frame(height: GalleryRailLayout.height)
        .contentMargins(.horizontal, GalleryRailLayout.horizontalInset, for: .scrollContent)
        .defaultScrollAnchor(.leading)
        .scrollTargetBehavior(.viewAligned)
    }

    @ViewBuilder
    private func galleryImage(name: String, width: CGFloat) -> some View {
        let shape = RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)

        GaiaAssetImage(name: name)
            .aspectRatio(contentMode: .fill)
            .frame(width: width, height: GalleryRailLayout.height)
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
