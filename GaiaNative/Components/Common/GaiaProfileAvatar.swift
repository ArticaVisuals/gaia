// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=870-13599
import SwiftUI

struct GaiaProfileAvatar: View {
    let imageName: String
    let size: CGFloat
    var borderWidth: CGFloat
    var strokeColor: Color = Color.black.opacity(0.1)
    var backgroundColor: Color = GaiaColor.blackishGrey100

    init(
        imageName: String,
        size: CGFloat,
        borderWidth: CGFloat? = nil,
        strokeColor: Color = Color.black.opacity(0.1),
        backgroundColor: Color = GaiaColor.blackishGrey100
    ) {
        self.imageName = imageName
        self.size = size
        self.borderWidth = borderWidth ?? (size / 96)
        self.strokeColor = strokeColor
        self.backgroundColor = backgroundColor
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .frame(width: size, height: size)

            if let image = AssetCatalog.image(named: imageName) {
                image
                    .resizable()
                    .interpolation(.high)
                    .scaledToFill()
                    .frame(width: size, height: size)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(strokeColor, lineWidth: borderWidth)
        )
    }
}
