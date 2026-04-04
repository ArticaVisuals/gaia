// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=465-2606
import SwiftUI

struct GaiaProjectCardCrop: Hashable {
    let scaleX: CGFloat
    let scaleY: CGFloat
    let left: CGFloat
    let top: CGFloat

    static let identity = Self(scaleX: 1, scaleY: 1, left: 0, top: 0)
}

struct GaiaProjectCard: View {
    static let height: CGFloat = 133
    static let width: CGFloat = 181

    let tag: String
    let title: String
    let countLabel: String
    let imageName: String
    var crop: GaiaProjectCardCrop = .identity
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topLeading) {
                GeometryReader { proxy in
                    let imageWidth = proxy.size.width * crop.scaleX
                    let imageHeight = proxy.size.height * crop.scaleY
                    let imageOffsetX = -(proxy.size.width * crop.left)
                    let imageOffsetY = -(proxy.size.height * crop.top)

                    ZStack {
                        GaiaAssetImage(name: imageName, contentMode: .fill)
                            .frame(width: imageWidth, height: imageHeight)
                            .offset(x: imageOffsetX, y: imageOffsetY)

                        GaiaAssetImage(name: imageName, contentMode: .fill)
                            .frame(width: imageWidth, height: imageHeight)
                            .offset(x: imageOffsetX, y: imageOffsetY)
                            .blur(radius: 1.4)
                            .mask(
                                LinearGradient(
                                    stops: [
                                        .init(color: .clear, location: 0.417),
                                        .init(color: .black, location: 1)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        LinearGradient(
                            stops: [
                                .init(color: GaiaColor.projectCardOverlay.opacity(0), location: 0.417),
                                .init(color: GaiaColor.projectCardOverlay.opacity(0.85), location: 1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                }
                .clipped()

                VStack(alignment: .leading, spacing: 0) {
                    Text(tag)
                        .gaiaFont(.caption)
                        .foregroundStyle(GaiaColor.paperWhite50)
                        .padding(.horizontal, GaiaSpacing.pillHorizontal)
                        .frame(height: 20)
                        .background(Color.black.opacity(0.5), in: Capsule())
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(GaiaColor.blackishGrey200, lineWidth: 0.5)
                        )
                        .padding(GaiaSpacing.cardInset)

                    Spacer(minLength: 0)

                    VStack(alignment: .leading, spacing: GaiaSpacing.xs) {
                        Text(title)
                            .font(GaiaTypography.subheadSerif)
                            .foregroundStyle(GaiaColor.paperWhite50)
                            .lineLimit(2)
                            .minimumScaleFactor(0.9)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(spacing: GaiaSpacing.xxs) {
                            GaiaProjectCardBinocularsIcon(tint: GaiaColor.paperWhite50)

                            Text(countLabel)
                                .font(GaiaTypography.caption)
                                .foregroundStyle(GaiaColor.paperWhite50)
                                .lineLimit(1)
                        }
                    }
                    .padding(GaiaSpacing.cardInset)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: Self.height)
            .background(GaiaColor.blackishGrey50)
            .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                    .stroke(GaiaColor.blackishGrey200, lineWidth: 0.5)
            )
            .shadow(color: GaiaShadow.cardColor, radius: GaiaShadow.cardRadius, x: 0, y: GaiaShadow.mdYOffset)
            .contentShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title), \(tag) project, \(countLabel) finds")
        .accessibilityHint("Opens the project details page")
    }
}

private struct GaiaProjectCardBinocularsIcon: View {
    let tint: Color

    var body: some View {
        Group {
            if let image = AssetCatalog.uiImage(named: "Icons/System/binoculars-20.png") {
                Image(uiImage: image)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(tint)
            } else {
                GaiaIcon(kind: .observe(selected: false), size: 14, tint: tint)
            }
        }
        .frame(width: 14, height: 10)
    }
}
