import SwiftUI

struct GalleryRail: View {
    let imageNames: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: GaiaSpacing.sm) {
                ForEach(imageNames, id: \.self) { imageName in
                    GaiaAssetImage(name: imageName)
                        .frame(width: 132, height: 92)
                        .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                                .stroke(GaiaColor.broccoliBrown100, lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, GaiaSpacing.md)
        }
    }
}
