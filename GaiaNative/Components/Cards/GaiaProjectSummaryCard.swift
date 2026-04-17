// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=1711-180935 (Project Card)
import SwiftUI

private enum GaiaProjectSummaryCardLayout {
    static let cardInset: CGFloat = GaiaSpacing.cardInset
    static let cardSpacing: CGFloat = GaiaSpacing.sm
    static let titleBlockSpacing: CGFloat = 6
    static let arrowGap: CGFloat = 17
    static let arrowSize: CGFloat = 20
    static let thumbnailAspectRatio: CGFloat = 157.0 / 57.0
}

struct GaiaProjectSummaryCard: View {
    let title: String
    let subtitle: String
    let location: String
    let imageName: String
    var width: CGFloat? = nil

    private var imageShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
    }

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaProjectSummaryCardLayout.cardSpacing) {
            thumbnail

            HStack(alignment: .bottom, spacing: GaiaProjectSummaryCardLayout.arrowGap) {
                VStack(alignment: .leading, spacing: GaiaProjectSummaryCardLayout.cardSpacing) {
                    VStack(alignment: .leading, spacing: GaiaProjectSummaryCardLayout.titleBlockSpacing) {
                        Text(title)
                            .gaiaFont(.body)
                            .foregroundStyle(GaiaColor.textPrimary)
                            .lineLimit(1)

                        Text(subtitle)
                            .gaiaFont(.caption)
                            .foregroundStyle(GaiaColor.inkBlack200)
                            .lineLimit(1)
                    }

                    HStack(alignment: .center, spacing: GaiaSpacing.xxs) {
                        GaiaIcon(kind: .pin, size: 13, tint: GaiaColor.broccoliBrown500)
                            .frame(width: 13, height: 15)

                        Text(location)
                            .gaiaFont(.caption)
                            .foregroundStyle(GaiaColor.broccoliBrown500)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                GaiaIcon(kind: .circleArrowRight, size: GaiaProjectSummaryCardLayout.arrowSize)
                    .frame(
                        width: GaiaProjectSummaryCardLayout.arrowSize,
                        height: GaiaProjectSummaryCardLayout.arrowSize
                    )
            }
        }
        .padding(GaiaProjectSummaryCardLayout.cardInset)
        .frame(width: width, alignment: .leading)
        .frame(maxWidth: width == nil ? .infinity : width, alignment: .leading)
        .background(
            cardShape
                .fill(GaiaColor.paperWhite50)
        )
        .clipShape(cardShape)
        .overlay(
            cardShape
                .stroke(GaiaColor.border, lineWidth: 0.5)
        )
        .contentShape(cardShape)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(subtitle), \(location)")
    }

    private var thumbnail: some View {
        ZStack {
            LinearGradient(
                colors: [GaiaColor.indigoBlue100, GaiaColor.paperWhite50],
                startPoint: .top,
                endPoint: .bottom
            )

            GaiaAssetImage(name: imageName, contentMode: .fill)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(GaiaProjectSummaryCardLayout.thumbnailAspectRatio, contentMode: .fit)
        .clipShape(imageShape)
        .overlay(
            imageShape
                .stroke(GaiaColor.border, lineWidth: 0.5)
        )
        .clipped()
    }
}
