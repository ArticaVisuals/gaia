import SwiftUI

struct GalleryRail: View {
    let imageNames: [String]

    private enum Layout {
        static let itemWidths: [CGFloat] = [223, 138, 104]
        static let itemHeight: CGFloat = 138
        static let itemSpacing: CGFloat = 8
        static let horizontalInset: CGFloat = GaiaSpacing.md
        static let cornerRadius: CGFloat = 9.867
        static let borderWidth: CGFloat = 1.233
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Layout.itemSpacing) {
                ForEach(Array(imageNames.enumerated()), id: \.offset) { index, imageName in
                    galleryImage(
                        name: imageName,
                        width: Layout.itemWidths[safe: index] ?? Layout.itemWidths.last ?? 104
                    )
                }
            }
            .padding(.horizontal, Layout.horizontalInset)
        }
    }

    private func galleryImage(name: String, width: CGFloat) -> some View {
        let shape = RoundedRectangle(cornerRadius: Layout.cornerRadius, style: .continuous)

        return GaiaAssetImage(name: name, contentMode: .fill)
            .frame(width: width, height: Layout.itemHeight)
            .clipShape(shape)
            .overlay(
                shape
                    .stroke(GaiaColor.broccoliBrown200, lineWidth: Layout.borderWidth)
            )
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
